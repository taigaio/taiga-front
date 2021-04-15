###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
