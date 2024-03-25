###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

LightboxDisplayHistoricDirective = (lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        ctrl._loadHistoric()
        lightboxService.open(el)

    return {
        scope: {},
        bindToController: {
            name: '=',
            object: '=',
            comment: '='
        },
        templateUrl:"history/history-lightbox/comment-history-lightbox.html",
        controller: "LightboxDisplayHistoricCtrl",
        controllerAs: "vm",
        link: link
    }

LightboxDisplayHistoricDirective.$inject = [
    "lightboxService"
]

angular.module('taigaHistory').directive("tgLbDisplayHistoric", LightboxDisplayHistoricDirective)
