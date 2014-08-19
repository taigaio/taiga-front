###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014 Alejandro Alonso <alejandro.alonso@kaleidos.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: modules/common/loader.coffee
###


taiga = @.taiga
sizeFormat = @.taiga.sizeFormat

module = angular.module("taigaCommon")

LoaderDirective = (tgLoader, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        tgLoader.onStart () ->
            $(document.body).addClass("loader-active")
            $el.addClass("active")

        tgLoader.onEnd () ->
            $(document.body).removeClass("loader-active")
            $el.removeClass("active")

        $rootscope.$on "$routeChangeSuccess", (e) ->
            tgLoader.start()

        $rootscope.$on "$locationChangeSuccess", (e) ->
            tgLoader.reset()

    return {
        link: link
    }

module.directive("tgLoader", ["tgLoader", "$rootScope", LoaderDirective])

Loader = () ->
    forceDisabled = false

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
            if !forceDisabled
                config.auto = auto
                config.enabled = true

    @.$get = ["$rootScope", ($rootscope) ->
        interval = null
        startLoadTime = 0

        reset = () ->
            log = _.merge({}, defaultLog)
            config = _.merge({}, defaultConfig)

        pageLoaded = (force = false) ->
            if startLoadTime
                timeout = 0

                if !force
                    endTime = new Date().getTime()
                    diff = endTime - startLoadTime

                    if diff < config.minTime
                        timeout = config.minTime - diff

                setTimeout ( ->
                    $rootscope.$broadcast("loader:end")
                ), timeout

        return {
            reset: () ->
                reset()

            pageLoaded: () ->
                pageLoaded()

            start: () ->
                if config.enabled
                    if config.auto
                        interval = setInterval ( ->
                            currentDate = new Date().getTime()

                            if log.request.count == log.response.count && currentDate - log.response.time  > 200
                                clearInterval(interval)
                                pageLoaded()

                        ), 100

                    startLoadTime = new Date().getTime()
                    $rootscope.$broadcast("loader:start")
                else
                    pageLoaded(true)

            onStart: (fn) ->
                $rootscope.$on("loader:start", fn)

            onEnd: (fn) ->
                $rootscope.$on("loader:end", fn)

            logRequest: () ->
                log.request.count++
                log.request.time = new Date().getTime()

            logResponse: () ->
                log.response.count++
                log.response.time = new Date().getTime()

            preventLoading: () ->
                forceDisabled = true

            disablePreventLoading: () ->
                forceDisabled = false
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
