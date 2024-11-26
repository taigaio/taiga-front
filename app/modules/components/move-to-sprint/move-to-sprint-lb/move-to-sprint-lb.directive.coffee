###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
