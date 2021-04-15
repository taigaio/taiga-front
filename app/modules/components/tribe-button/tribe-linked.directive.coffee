###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

TribeLinkedDirective = (configService) ->
    link = (scope, el, attrs) ->

        scope.vm = {}

        scope.vm.tribeHost = configService.config.tribeHost

        scope.vm.show = () ->
            scope.vm.open = true

        scope.vm.hide = (event) ->
            scope.vm.open = false

    directive = {
        templateUrl: "components/tribe-button/tribe-linked.html",
        scope: {
            gigTitle: "=",
            gigId: "="
        },
        link: link
    }

    return directive

TribeLinkedDirective.$inject = [
    "$tgConfig"
]

angular.module("taigaComponents").directive("tgTribeLinked", TribeLinkedDirective)
