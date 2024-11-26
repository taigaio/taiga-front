###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module('taigaHistory')

HistoryTabsDirective = () ->
    return {
        templateUrl:"history/history-tabs/history-tabs.html",
        scope: {
            showCommentTab: "&",
            showActivityTab: "&"
            onActiveComments: "&",
            onActiveActivities: "&",
            onOrderComments: "&"
            activeTab: "<",
            commentsNum: "<",
            activitiesNum: "<",
            onReverse: "<"
        }
    }

module.directive("tgHistoryTabs", HistoryTabsDirective)
