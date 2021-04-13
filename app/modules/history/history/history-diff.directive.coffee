module = angular.module('taigaHistory')

HistoryDiffDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.diffTags()
    return {
        scope: {
            model: "<",
            type: "<",
            diff: "<"
        },
        templateUrl:"history/history/history-diff.html",
        controller: "ActivitiesDiffCtrl",
        controllerAs: 'vm',
        bindToController: true,
        link: link
    }

module.directive("tgHistoryDiff", HistoryDiffDirective)
