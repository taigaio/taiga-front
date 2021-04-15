###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
        }
    }

HistorySectionDirective.$inject = []

module.directive("tgHistorySection", HistorySectionDirective)
