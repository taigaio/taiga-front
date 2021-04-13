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
