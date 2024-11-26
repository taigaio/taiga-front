###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
