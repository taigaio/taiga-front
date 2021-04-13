module = angular.module('taigaHistory')

bindOnce = @.taiga.bindOnce

HistorySectionDirective = () ->
    link = (scope, el, attr, ctrl) ->
        scope.$on "object:updated", -> ctrl._loadActivity()

        scope.$watch 'vm.id', (value) ->
            ctrl._loadHistory()

    return {
        link: link,
        templateUrl:"history/history.html",
        controller: "HistorySection",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            type: "=",
            name: "@",
            id: "=",
            project: "="
        }
    }

HistorySectionDirective.$inject = []

module.directive("tgHistorySection", HistorySectionDirective)
