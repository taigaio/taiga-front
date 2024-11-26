###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
