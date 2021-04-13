module = angular.module('taigaWikiHistory')

WikiHistoryDiffDirective = () ->
    return {
        templateUrl:"wiki/history/wiki-history-diff.html",
        scope: {
            key: "<",
            diff: "<"
        }
    }

module.directive("tgWikiHistoryDiff", WikiHistoryDiffDirective)
