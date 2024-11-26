###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module('taigaHistory')

HistoryDiffDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.diffTags()
    return {
        scope: {
            model: "<",
            type: "<",
            diff: "<"
        },
        templateUrl:"history/history/history-diff.html",
        controller: "ActivitiesDiffCtrl",
        controllerAs: 'vm',
        bindToController: true,
        link: link
    }

module.directive("tgHistoryDiff", HistoryDiffDirective)
