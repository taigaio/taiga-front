taiga = @.taiga
sizeFormat = @.taiga.sizeFormat

module = angular.module("taigaCommon")

LoaderDirective = (tgLoader) ->
    link = ($scope, $el, $attrs) ->
        tgLoader.onStart () ->
            $(document.body).addClass("loader-active")
            $el.addClass("active")

        tgLoader.onEnd () ->
            $(document.body).removeClass("loader-active")
            $el.removeClass("active")

        $scope.$on "$routeChangeSuccess", () ->
            tgLoader.start()

    return {
        link: link
    }

module.directive("tgLoader", ["tgLoader", LoaderDirective])

Loader = () ->
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
        minTime: 1000,
        auto: false
    }

    log = _.merge({}, defaultLog)
    config = _.merge({}, defaultConfig)

    @.add = (auto = false) ->
        return () ->
            config.auto = auto
            config.enabled = true

    @.$get = ["$rootScope", ($rootscope) ->
        interval = null
        startLoadTime = 0

        return {
            pageLoaded: () ->
                if config.enabled
                    log = _.merge({}, defaultLog)
                    config = _.merge({}, defaultConfig)

                    endTime = new Date().getTime()
                    diff = endTime - startLoadTime

                    if diff < config.minTime
                        timeout = config.minTime - diff
                    else
                        timeout = 0

                    setTimeout ( ->
                        $rootscope.$broadcast("loader:end");
                    ), timeout

            start: () ->
                config.enabled = false
                if config.enabled
                    if config.auto
                        interval = setInterval ( ->
                            currentDate = new Date().getTime()

                            if log.request.count == log.response.count && currentDate - log.response.time  > 200
                                clearInterval(interval)
                                pageLoaded()

                        ), 100

                    startLoadTime = new Date().getTime()
                    $rootscope.$broadcast("loader:start");

            onStart: (fn) ->
                $rootscope.$on("loader:start", fn);

            onEnd: (fn) ->
                $rootscope.$on("loader:end", fn);

            logRequest: () ->
                log.request.count++
                log.request.time = new Date().getTime()

            logResponse: () ->
                log.response.count++
                log.response.time = new Date().getTime()

            isEneabled: () ->
                config.enabled == true

            disabled: () ->
                config.enabled = false

            enabled: () ->
                config.enabled = true
        }
    ]

    return

module.provider("tgLoader", [Loader])

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
