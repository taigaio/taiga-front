###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module('taigaHistory')

bindOnce = @.taiga.bindOnce

HistorySectionDirective = () ->
    link = (scope, el, attr, ctrl) ->
        scope.$on "object:updated", -> ctrl._loadActivity()

        scope.$watch 'vm.id', (value) ->
            ctrl._loadHistory()

    return {
        link: link,
        templateUrl:"history/history.html",
        controller: "HistorySection",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            type: "=",
            name: "@",
            id: "=",
            project: "="
            totalComments: "="
        }
    }

HistorySectionDirective.$inject = []

module.directive("tgHistorySection", HistorySectionDirective)
