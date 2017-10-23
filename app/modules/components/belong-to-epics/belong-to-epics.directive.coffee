###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: belong-to-epics.directive.coffee
###

module = angular.module('taigaEpics')

BelongToEpicsDirective = () ->

    link = (scope, el, attrs) ->
        scope.$watch 'epics', (epics) ->
            if epics && !epics.isIterable
              scope.immutable_epics = Immutable.fromJS(epics)

    templateUrl = (el, attrs) ->
        if attrs.format
            return "components/belong-to-epics/belong-to-epics-" + attrs.format + ".html"
        return "components/belong-to-epics/belong-to-epics-pill.html"

    return {
        link: link,
        scope: {
            epics: '='
        },
        templateUrl: templateUrl
    }


module.directive("tgBelongToEpics", BelongToEpicsDirective)
