###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
