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
# File: modules/base/location.coffee
###


locationFactory = ($location, $route, $rootscope) ->
    $location.noreload =  (scope) ->
        lastRoute = $route.current
        un = scope.$on "$locationChangeSuccess", ->
            $route.current = lastRoute
            un()

        return $location

    $location.isInCurrentRouteParams = (name, value) ->
        params = $location.search() || {}

        return params[name] == value

    return $location


module = angular.module("taigaBase")
module.factory("$tgLocation", ["$location", "$route", "$rootScope", locationFactory])
