module = angular.module('taigaHistory')

HistoryDirective = () ->
    link = (scope, el, attrs) ->

    return {
        scope: {
            activities: "<",
            model: "<",
        },
        templateUrl:"history/history/history.html",
        link: link
    }

module.directive("tgHistory", HistoryDirective)
