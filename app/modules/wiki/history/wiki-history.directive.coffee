bindOnce = @.taiga.bindOnce

module = angular.module('taigaWikiHistory')


WikiHistoryDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        bindOnce scope, 'vm.wikiId', (value) ->
            ctrl.initializeHistory(value)

    return {
        scope: {},
        bindToController: {
            wikiId: "<"
        }
        controller: "WikiHistoryCtrl",
        controllerAs: "vm",
        templateUrl:"wiki/history/wiki-history.html",
        link: link
    }

module.directive("tgWikiHistory", WikiHistoryDirective)
