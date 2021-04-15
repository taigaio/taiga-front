###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
