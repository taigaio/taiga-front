###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: /modules/components/swimlane-selector/swimlane-selector.directive.coffee
###

taiga = @.taiga
timeout = @.taiga.timeout
cancelTimeout = @.taiga.cancelTimeout

#############################################################################
## Swimlane Selector
#############################################################################

SwimlaneSelector = ($timeout) ->

    link = (scope, el, attrs) ->

        scope.displaySelector = false
        timeout = null

        mount = () ->
            getCurrentSwimlane()

        getCurrentSwimlane = () ->
            if (scope.currentSwimlaneId)
                filteredSwimlanes = scope.swimlanes.filter (swimlane) ->
                    return swimlane.id == scope.currentSwimlaneId

                scope.currentSwimlane = filteredSwimlanes.get(0);
            else
                filteredSwimlanes = scope.swimlanes.filter (swimlane) ->
                    return swimlane.id == scope.defaultSwimlaneId


                scope.currentSwimlane = filteredSwimlanes.get(0);

        scope.displayOptions = () ->
            if (timeout)
                $timeout.cancel(timeout)
                timeout = null
            scope.displaySelector = true

        scope.hideOptions = () ->
            timeout = $timeout (() ->
                scope.displaySelector = false
            ), 100

        scope.selectSwimlane = (swimlane) ->
            if (swimlane)
                scope.ngModel = swimlane.id
                scope.currentSwimlane = swimlane
                scope.hideOptions()

        scope.$watch 'currentSwimlaneId', (swimlaneId) ->
            getCurrentSwimlane()

        mount()

    return {
        link: link,
        templateUrl: "components/swimlane-selector/swimlane-selector.html",
        scope: {
            swimlanes: '<',
            currentSwimlaneId: '<',
            defaultSwimlaneId: '<',
            ngModel : '=',
        },
        require: "ngModel"
    }

angular.module('taigaComponents').directive("tgSwimlaneSelector", ['$timeout', SwimlaneSelector])
