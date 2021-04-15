###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module('taigaEpics')

RelatedUserstoryRowDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.setAvatarData()

    return {
        link: link,
        templateUrl:"epics/related-userstories/related-userstory-row/related-userstory-row.html",
        controller: "RelatedUserstoryRowCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            userstory: '='
            epic: '='
            project: '='
            loadRelatedUserstories:"&"
        }
    }

RelatedUserstoryRowDirective.$inject = []

module.directive("tgRelatedUserstoryRow", RelatedUserstoryRowDirective)
