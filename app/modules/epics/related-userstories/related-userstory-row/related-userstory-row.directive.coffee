###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
