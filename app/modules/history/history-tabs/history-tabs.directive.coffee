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
