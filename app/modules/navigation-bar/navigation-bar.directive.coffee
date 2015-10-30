###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: navigation-bar.directive.coffee
###

NavigationBarDirective = (currentUserService, navigationBarService, $location) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        scope.$on "$routeChangeSuccess", () ->
            if $location.path() == "/"
                scope.vm.active = true
            else
                scope.vm.active = false

        taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("recents"))
        taiga.defineImmutableProperty(scope.vm, "isAuthenticated", () -> currentUserService.isAuthenticated())
        taiga.defineImmutableProperty(scope.vm, "isEnabledHeader", () -> navigationBarService.isEnabledHeader())


    directive = {
        templateUrl: "navigation-bar/navigation-bar.html"
        scope: {}
        link: link
    }

    return directive

NavigationBarDirective.$inject = [
    "tgCurrentUserService",
    "tgNavigationBarService"
    "$location"
]

angular.module("taigaNavigationBar").directive("tgNavigationBar", NavigationBarDirective)
