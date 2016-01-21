###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/lightboxes.coffee
###

module = angular.module("taigaCommon")

TgLoadingService = ($compile) ->
    spinner = "<img class='loading-spinner' src='/" + window._version + "/svg/spinner-circle.svg' alt='loading...' />"

    return () ->
        service = {
            settings: {
                target: null,
                scope: null,
                classes: []
                timeout: 0,
                template: null
            },
            target: (target) ->
                service.settings.target = target

                return service
            scope: (scope) ->
                service.settings.scope = scope

                return service
            template: (template) ->
                service.settings.template = template

                return service
            removeClasses: (classess...) ->
                service.settings.classes = classess

                return service
            timeout: (timeout) ->
                service.settings.timeout = timeout

                return service

            start: ->
                target = service.settings.target
                service.settings.classes.map (className) -> target.removeClass(className)

                # The loader is shown after that quantity of milliseconds
                timeoutId = setTimeout (->
                    if not target.hasClass('loading')
                        if !service.settings.template
                            service.settings.template = target.html()

                        target.addClass('loading')

                        target.html(spinner)
                    ), service.settings.timeout

                service.settings.timeoutId = timeoutId

                return service

            finish: ->
                target = service.settings.target
                timeoutId = service.settings.timeoutId

                if timeoutId
                    clearTimeout(timeoutId)

                    removeClasses = service.settings.classes
                    removeClasses.map (className) -> service.settings.target.addClass(className)

                    target.html(service.settings.template)
                    target.removeClass('loading')

                    if service.settings.scope
                        $compile(target.contents())(service.settings.scope)

                return service
        }

        return service

TgLoadingService.$inject = [
    "$compile"
]

module.factory("$tgLoading", TgLoadingService)

LoadingDirective = ($loading) ->
    link = ($scope, $el, attr) ->
        currentLoading = null
        template = $el.html()

        $scope.$watch attr.tgLoading, (showLoading) =>
            if showLoading
                currentLoading = $loading()
                    .target($el)
                    .timeout(100)
                    .template(template)
                    .scope($scope)
                    .start()
             else if currentLoading
                 currentLoading.finish()

    return {
        link:link
    }

module.directive("tgLoading", ["$tgLoading", LoadingDirective])
