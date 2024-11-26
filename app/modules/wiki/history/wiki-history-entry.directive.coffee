###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module('taigaWikiHistory')

WikiHistoryEntryDirective = () ->
    link = (scope, el, attr) ->
        scope.singleHistoryEntry = scope.historyEntry.toJS()

    return {
        link: link,
        templateUrl:"wiki/history/wiki-history-entry.html",
        scope: {
            historyEntry: "<"
        }
    }

module.directive("tgWikiHistoryEntry", WikiHistoryEntryDirective)
