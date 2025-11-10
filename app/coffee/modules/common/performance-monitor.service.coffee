###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
module = angular.module("taigaCommon")


class PerformanceMonitorService extends taiga.Service
    @.$inject = ["$window", "$log", "$tgConfig"]

    constructor: (@win, @log, @config) ->
        @.enabled = false
        @.metrics = []
        @.maxMetrics = 100
        @.apiTimings = {}
        @.rootScope = null

    initialize: ->
        conf = @config.get("performanceMonitor", {})
        @.enabled = conf.enabled ? false

        if not @.enabled
            @log.debug "Performance Monitor: disabled in config"
            return

        # Get $rootScope through injector to avoid circular dependency
        try
            injector = angular.element(document).injector()
            @.rootScope = injector.get("$rootScope") if injector
        catch error
            @log.warn "Performance Monitor: could not get $rootScope"

        if @.rootScope
            @.setupNavigationTimingTracking()
            @.setupResourceTimingTracking()
        
        @.setupMemoryTracking()

        @log.debug "Performance Monitor: initialized"

    setupNavigationTimingTracking: ->
        return if not @win.performance?.timing
        return if not @.rootScope

        @rootScope.$on "$routeChangeSuccess", (event, current, previous) =>
            setTimeout =>
                @._recordNavigationMetrics(current, previous)
            , 100

    setupResourceTimingTracking: ->
        return if not @win.performance?.getEntriesByType
        return if not @.rootScope

        @rootScope.$on "$routeChangeSuccess", =>
            setTimeout =>
                @._recordResourceMetrics()
            , 500

    setupMemoryTracking: ->
        return if not @win.performance?.memory

        setInterval =>
            @._recordMemoryMetrics()
        , 30000

    _recordNavigationMetrics: (current, previous) ->
        return if not @win.performance?.timing

        timing = @win.performance.timing
        navigationStart = timing.navigationStart

        metrics = {
            type: "navigation"
            timestamp: Date.now()
            route: current?.$$route?.originalPath or "unknown"
            previousRoute: previous?.$$route?.originalPath or null
            dns: timing.domainLookupEnd - timing.domainLookupStart
            tcp: timing.connectEnd - timing.connectStart
            request: timing.responseStart - timing.requestStart
            response: timing.responseEnd - timing.responseStart
            domParsing: timing.domInteractive - timing.domLoading
            domReady: timing.domContentLoadedEventEnd - timing.domContentLoadedEventStart
            pageLoad: timing.loadEventEnd - timing.loadEventStart
            totalTime: timing.loadEventEnd - navigationStart
        }

        @._addMetric(metrics)
        @._checkPerformanceThresholds(metrics)

    _recordResourceMetrics: ->
        return if not @win.performance?.getEntriesByType

        resources = @win.performance.getEntriesByType("resource")
        slowResources = resources.filter (resource) -> resource.duration > 500

        if slowResources.length > 0
            metrics = {
                type: "slow_resources"
                timestamp: Date.now()
                count: slowResources.length
                resources: slowResources.map (r) ->
                    name: r.name.split("/").pop()
                    duration: Math.round(r.duration)
                    size: r.transferSize or 0
            }
            @._addMetric(metrics)

    _recordMemoryMetrics: ->
        return if not @win.performance?.memory

        memory = @win.performance.memory

        metrics = {
            type: "memory"
            timestamp: Date.now()
            usedHeap: Math.round(memory.usedJSHeapSize / 1048576)
            totalHeap: Math.round(memory.totalJSHeapSize / 1048576)
            heapLimit: Math.round(memory.jsHeapSizeLimit / 1048576)
        }

        @._addMetric(metrics)

        if metrics.usedHeap > metrics.heapLimit * 0.9
            @log.warn "Memory usage high:", metrics

    recordApiTiming: (config, duration, status) ->
        return if not @.enabled

        url = config.url
        method = config.method

        key = "#{method} #{url}"

        if not @.apiTimings[key]
            @.apiTimings[key] = {
                url: url
                method: method
                count: 0
                totalDuration: 0
                minDuration: Infinity
                maxDuration: 0
                errors: 0
            }

        timing = @.apiTimings[key]
        timing.count++
        timing.totalDuration += duration
        timing.minDuration = Math.min(timing.minDuration, duration)
        timing.maxDuration = Math.max(timing.maxDuration, duration)

        if status >= 400
            timing.errors++

        if duration > 3000
            @log.warn "Slow API request:", {
                url: url
                method: method
                duration: Math.round(duration)
                status: status
            }

    recordError: (error, context) ->
        return if not @.enabled

        metrics = {
            type: "error"
            timestamp: Date.now()
            message: error.message or error.toString()
            stack: error.stack?.substring(0, 500)
            context: context
            userAgent: @win.navigator.userAgent
            url: @win.location.href
        }

        @._addMetric(metrics)

    _addMetric: (metric) ->
        @.metrics.push(metric)

        if @.metrics.length > @.maxMetrics
            @.metrics.shift()

    _checkPerformanceThresholds: (metrics) ->
        if metrics.totalTime > 5000
            @log.warn "Slow page load:", {
                route: metrics.route
                totalTime: Math.round(metrics.totalTime)
            }

        if metrics.domParsing > 2000
            @log.warn "Slow DOM parsing:", {
                route: metrics.route
                domParsing: Math.round(metrics.domParsing)
            }

    getMetrics: ->
        return {
            recent: @.metrics.slice(-20)
            apiTimings: @._getApiSummary()
            summary: @._getSummary()
        }

    _getApiSummary: ->
        summary = []
        for key, timing of @.apiTimings
            summary.push {
                endpoint: key
                count: timing.count
                avgDuration: Math.round(timing.totalDuration / timing.count)
                minDuration: Math.round(timing.minDuration)
                maxDuration: Math.round(timing.maxDuration)
                errorRate: if timing.count > 0 then Math.round(timing.errors / timing.count * 100) else 0
            }

        return summary.sort (a, b) -> b.avgDuration - a.avgDuration

    _getSummary: ->
        navigationMetrics = @.metrics.filter (m) -> m.type is "navigation"
        errorMetrics = @.metrics.filter (m) -> m.type is "error"

        avgLoadTime = 0
        if navigationMetrics.length > 0
            totalLoadTime = navigationMetrics.reduce ((sum, m) -> sum + (m.totalTime or 0)), 0
            avgLoadTime = Math.round(totalLoadTime / navigationMetrics.length)

        return {
            totalMetrics: @.metrics.length
            navigationCount: navigationMetrics.length
            errorCount: errorMetrics.length
            avgPageLoadTime: avgLoadTime
            apiEndpointsTracked: Object.keys(@.apiTimings).length
        }

    clear: ->
        @.metrics = []
        @.apiTimings = {}

module.service("tgPerformanceMonitor", PerformanceMonitorService)
