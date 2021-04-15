###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaComponents")

moveToSprintLightboxDirective = (lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        lightboxService.open(el)

    return {
        scope: {}
        bindToController: {
            openItems: "="
            sprint: "="
        },
        templateUrl: "components/move-to-sprint/move-to-sprint-lb/move-to-sprint-lb.html"
        controller: "MoveToSprintLbCtrl"
        controllerAs: "vm"
        link: link
    }

moveToSprintLightboxDirective.$inject = [
    "lightboxService"
]

module.directive("tgLbMoveToSprint", moveToSprintLightboxDirective)
