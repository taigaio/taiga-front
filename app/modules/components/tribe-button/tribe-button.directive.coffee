###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
