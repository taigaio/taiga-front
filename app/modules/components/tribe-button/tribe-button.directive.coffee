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
# File: components/tribe-button/tribe-button.directive.coffee
###

TribeButtonDirective = (configService, locationService) ->
    link = (scope, el, attrs) ->

        scope.vm = {}
        scope.vm.tribeHost = configService.config.tribeHost
        scope.vm.url = "#{locationService.protocol()}://#{locationService.host()}"
        if (locationService.protocol() == "http" and locationService.port() != 80)
            scope.vm.url = "#{scope.vm.url}:#{locationService.port()}"
        else if (locationService.protocol() == "https" and locationService.port() != 443)
            scope.vm.url = "#{scope.vm.url}:#{locationService.port()}"

    return {
        scope: {usId: "=", projectSlug: "="}
        controllerAs: "vm",
        templateUrl: "components/tribe-button/tribe-button.html",
        link: link
    }

TribeButtonDirective.$inject = [
    "$tgConfig", "$tgLocation"
]

angular.module("taigaComponents").directive("tgTribeButton", TribeButtonDirective)
