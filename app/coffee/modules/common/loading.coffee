###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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

TgLoadingService = ->
    spinner = "<img class='loading-spinner' src='/svg/spinner-circle.svg' alt='loading...' />"

    return () ->
        service = {
            settings: {
                target: null,
                classes: []
                timeout: 0
            },
            target: (target) ->
                service.settings.target = target

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
                        service.settings.oldContent = target.html()

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

                    target.html(service.settings.oldContent)
                    target.removeClass('loading')

                return service
        }

        return service

module.factory("$tgLoading", TgLoadingService)

LoadingDirective = ($loading) ->
    link = ($scope, $el, attr) ->
        currentLoading = null

        $scope.$watch attr.tgLoading, (showLoading) =>

            if showLoading
                currentLoading = $loading()
                    .target($el)
                    .start()
             else
                 currentLoading.finish()

    return {
        link:link
    }

module.directive("tgLoading", ["$tgLoading", LoadingDirective])
