HistoryEntryDirective = () ->
    return {
        scope: {
            entry: "<"
        },
        templateUrl:"history/history-lightbox/history-entry.html",
    }

angular.module('taigaHistory').directive("tgHistoryEntry", HistoryEntryDirective)
