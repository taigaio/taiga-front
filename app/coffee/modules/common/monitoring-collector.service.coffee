###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
module = angular.module("taigaCommon")


class MonitoringCollectorService extends taiga.Service
    @.$inject = [
        "$window",
        "$log",
        "$tgConfig",
        "tgPerformanceMonitor",
        "tgErrorHandlingService"
    ]

    constructor: (@win, @log, @config, @performanceMonitor, @errorHandlingService) ->
        @.enabled = false
        @.reportInterval = 300000
        @.reportTimer = null

    initialize: ->
        conf = @config.get("monitoring", {})
        @.enabled = conf.enabled ? false
        @.reportInterval = conf.reportInterval ? 300000

        if not @.enabled
            @log.debug "Monitoring Collector: disabled in config"
            return

        @performanceMonitor.initialize()

        if @.reportInterval > 0
            @.startPeriodicReporting()

        @.exposeDebugInterface()

        @log.debug "Monitoring Collector: initialized"

    startPeriodicReporting: ->
        @.reportTimer = setInterval =>
            @._generateReport()
        , @.reportInterval

    stopPeriodicReporting: ->
        if @.reportTimer
            clearInterval(@.reportTimer)
            @.reportTimer = null

    _generateReport: ->
        return if not @.enabled

        report = {
            timestamp: Date.now()
            performance: @performanceMonitor.getMetrics()
            errors: @errorHandlingService.getErrorHistory()
            environment: @._getEnvironmentInfo()
        }

        @log.info "Performance Report:", report

        endpoint = @config.get("monitoring.reportEndpoint", null)
        if endpoint
            @._sendReport(endpoint, report)

        return report

    _sendReport: (endpoint, report) ->
        try
            if @win.navigator.sendBeacon
                blob = new Blob([JSON.stringify(report)], {type: 'application/json'})
                @win.navigator.sendBeacon(endpoint, blob)
            else
                @log.warn "sendBeacon not supported, skipping report"
        catch error
            @log.error "Failed to send monitoring report:", error

    _getEnvironmentInfo: ->
        return {
            userAgent: @win.navigator.userAgent
            language: @win.navigator.language
            viewport: {
                width: @win.innerWidth
                height: @win.innerHeight
            }
            screen: {
                width: @win.screen.width
                height: @win.screen.height
            }
            connection: @._getConnectionInfo()
        }

    _getConnectionInfo: ->
        return null if not @win.navigator.connection

        conn = @win.navigator.connection
        return {
            effectiveType: conn.effectiveType
            downlink: conn.downlink
            rtt: conn.rtt
            saveData: conn.saveData
        }

    exposeDebugInterface: ->
        @win.TaigaMonitoring = {
            getReport: => @._generateReport()
            getPerformanceMetrics: => @performanceMonitor.getMetrics()
            getErrors: => @errorHandlingService.getErrorHistory()
            clearMetrics: => 
                @performanceMonitor.clear()
                @errorHandlingService.clearErrorHistory()
                @log.info "Monitoring data cleared"
        }

        @log.debug "Debug interface exposed at window.TaigaMonitoring"

module.service("tgMonitoringCollector", MonitoringCollectorService)
