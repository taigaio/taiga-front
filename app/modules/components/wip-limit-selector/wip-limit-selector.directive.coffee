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

WipLimitSelector = ($timeout) ->

    link = (scope, el, attrs) ->

        scope.displayWipLimitSelector = false

        scope.toggleWipSelectorVisibility = () ->
            scope.displayWipLimitSelector = !scope.displayWipLimitSelector

    return {
        link: link,
        scope: {}
        templateUrl: "components/wip-limit-selector/wip-limit-selector.html",
        controller: "ProjectSwimlanesWipLimit",
        bindToController: {
            status: '=',
        }
        controllerAs: "vm",
    }

angular.module('taigaComponents').directive("tgWipLimitSelector", [WipLimitSelector])
