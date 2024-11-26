###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
