###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaComponents")

cardDirective = () ->
    return {
        controller: "Card",
        controllerAs: "vm",
        templateUrl: "components/card/card.html",
        bindToController: {
            onToggleFold: "&",
            onClickAssignedTo: "&",
            onClickEdit: "&",
            onClickRemove: "&",
            onClickDelete: "&",
            onClickMoveToTop: "&",
            project: "<",
            item: "<",
            zoom: "<",
            zoomLevel: "<",
            archived: "<",
            inViewPort: "<",
            folded: "<",
            type: "@",
            isFirst: "<"
        }
    }

module.directive('tgCard', cardDirective)
