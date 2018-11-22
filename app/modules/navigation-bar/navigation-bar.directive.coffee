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
# File: navigation-bar/navigation-bar.directive.coffee
###

NavigationBarDirective = (currentUserService, navigationBarService, locationService, navUrlsService, config) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("recents"))
        taiga.defineImmutableProperty(scope.vm, "isAuthenticated", () -> currentUserService.isAuthenticated())
        taiga.defineImmutableProperty(scope.vm, "isEnabledHeader", () -> navigationBarService.isEnabledHeader())

        scope.vm.publicRegisterEnabled = config.get("publicRegisterEnabled")
        scope.vm.customSupportUrl = config.get("supportUrl")

        scope.vm.login = ->
            nextUrl = encodeURIComponent(locationService.url())
            locationService.url(navUrlsService.resolve("login"))
            locationService.search({next: nextUrl})

        scope.$on "$routeChangeSuccess", () ->
            scope.vm.active = null
            switch locationService.path()
                when "/"
                    scope.vm.active = 'dashboard'
                when "/discover"
                    scope.vm.active = 'discover'
                when "/notifications"
                    scope.vm.active = 'notifications'
                when "/projects/"
                    scope.vm.active = 'projects'

    directive = {
        templateUrl: "navigation-bar/navigation-bar.html"
        scope: {}
        link: link
    }

    return directive

NavigationBarDirective.$inject = [
    "tgCurrentUserService",
    "tgNavigationBarService",
    "$tgLocation",
    "$tgNavUrls",
    "$tgConfig"
]

angular.module("taigaNavigationBar").directive("tgNavigationBar", NavigationBarDirective)
