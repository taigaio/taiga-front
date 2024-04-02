###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module('taigaEpics')

RelatedUserStoriesDirective = () ->
    return {
        templateUrl:"epics/related-userstories/related-userstories.html",
        controller: "RelatedUserStoriesCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            userstories: '=',
            project: '='
            epic: '='
        }
    }

RelatedUserStoriesDirective.$inject = []

module.directive("tgRelatedUserstories", RelatedUserStoriesDirective)
