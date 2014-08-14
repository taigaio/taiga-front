taiga = @.taiga
sizeFormat = @.taiga.sizeFormat

module = angular.module("taigaCommon")

LoaderDirective = (tgLoader) ->
    link = ($scope, $el, $attrs) ->
        tgLoader.end () ->
            $el.removeClass("active")

        $scope.$on "$routeChangeSuccess", () ->
            tgLoader.start () ->
                $el.addClass("active")


    return {
        link: link
    }

module.directive("tgLoader", ["tgLoader", LoaderDirective])

Loader = () ->
    interval = null
    onLoad = () ->
    startLoadTime = 0

    defaultLog = {
        request: {
            count: 0,
            time: 0
        }
        response: {
            count: 0,
            time: 0
        }
    }

    defaultConfig = {
        enabled: false,
        minTime: 3000,
        auto: false
    }

    log = _.merge({}, defaultLog)
    config = _.merge({}, defaultConfig)

    reset = () ->
        log = _.merge({}, defaultLog)
        config = _.merge({}, defaultConfig)

    pageLoaded = () ->
        reset()

        endTime = new Date().getTime()
        diff = endTime - startLoadTime

        if diff < config.minTime
            timeout = config.minTime - diff
        else
            timeout = 0

        setTimeout ( ->
            onLoad()
        ), timeout

    autoCheckLoad = () ->
        interval = setInterval ( ->
            currentDate = new Date().getTime()

            if log.request.count == log.response.count && currentDate - log.response.time  > 200
                clearInterval(interval)
                pageLoaded()

        ), 100

    @.add = (auto = false) ->
        return () ->
            config.enabled = true
            config.auto = auto

    @.$get = () ->
        return {
            start: (callback) ->
                if config.enabled
                    if config.auto
                        autoCheckLoad()

                    startLoadTime = new Date().getTime()
                    callback()

            end: (fn) ->
                onLoad = fn

            pageLoaded: () ->
                pageLoaded()

            logRequest: () ->
                log.request.count++
                log.request.time = new Date().getTime()

            logResponse: () ->
                log.response.count++
                log.response.time = new Date().getTime()
        }

    return

module.provider("tgLoader", Loader)

loaderInterceptor = (tgLoader) ->
    return {
        request: (config) ->
            tgLoader.logRequest()

            return config
        response: (response) ->
            tgLoader.logResponse()

            return response
    }

module.factory('loaderInterceptor', ['tgLoader', loaderInterceptor])
