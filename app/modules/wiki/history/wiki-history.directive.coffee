###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

bindOnce = @.taiga.bindOnce

module = angular.module('taigaWikiHistory')


WikiHistoryDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        bindOnce scope, 'vm.wikiId', (value) ->
            ctrl.initializeHistory(value)

    return {
        scope: {},
        bindToController: {
            wikiId: "<"
        }
        controller: "WikiHistoryCtrl",
        controllerAs: "vm",
        templateUrl:"wiki/history/wiki-history.html",
        link: link
    }

module.directive("tgWikiHistory", WikiHistoryDirective)
