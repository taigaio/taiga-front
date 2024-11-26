###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

HistoryEntryDirective = () ->
    return {
        scope: {
            entry: "<"
        },
        templateUrl:"history/history-lightbox/history-entry.html",
    }

angular.module('taigaHistory').directive("tgHistoryEntry", HistoryEntryDirective)
