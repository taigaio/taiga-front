###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
