###
# Copyright (C) 2014-present Taiga Agile LLC
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

SwimlaneSelector = ($timeout, $translate) ->

    link = (scope, el, attrs) ->

        scope.displaySelector = false
        scope.selectedSwimlane = null
        timeout = null

        mount = () ->
            getCurrentSwimlane()

        getCurrentSwimlane = () ->
            if (scope.userStory.id)
                if (scope.userStory.swimlane)
                    filteredSwimlanes = scope.swimlanes.filter (swimlane) ->
                        return swimlane.id == scope.userStory.swimlane

                    scope.currentSwimlane = filteredSwimlanes.get(0)
                else
                    scope.currentSwimlane = null
            else
                filteredSwimlanes = scope.swimlanes.filter (swimlane) ->
                    return swimlane.id == scope.defaultSwimlaneId

                scope.currentSwimlane = filteredSwimlanes.get(0)
            getSelectedSwimlane()

        getSelectedSwimlane = () ->
            if (scope.userStory.id)
                if (scope.currentSwimlane)
                    scope.selectedSwimlane = scope.currentSwimlane.id
                else
                    scope.selectedSwimlane = null
            else
                scope.selectedSwimlane = scope.currentSwimlane.id

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
            if (swimlane == 'noSwimlane')
                swimlane = {
                    id: null,
                    kanban_order: 1,
                    name: $translate.instant("KANBAN.UNCLASSIFIED_USER_STORIES")
                }
                scope.ngModel = swimlane.id
                scope.currentSwimlane = swimlane
                scope.hideOptions()
            else
                scope.ngModel = if swimlane.id != -1 then swimlane.id else null
                scope.currentSwimlane = swimlane
                scope.hideOptions()

            getSelectedSwimlane()

        scope.$watch 'userStory', (userStory) ->
            getCurrentSwimlane()

        mount()

    return {
        link: link,
        templateUrl: "components/swimlane-selector/swimlane-selector.html",
        scope: {
            swimlanes: '<',
            defaultSwimlaneId: '<',
            userStory: '<'
            hasUnclassifiedStories: '<'
            ngModel : '=',
        },
        require: "ngModel"
    }

angular.module('taigaComponents').directive("tgSwimlaneSelector", ['$timeout', "$translate", SwimlaneSelector])
