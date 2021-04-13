TrelloImportDirective = () ->
    return {
        link: (scope, elm, attrs, ctrl) ->
            ctrl.startProjectSelector()
        templateUrl:"projects/create/trello-import/trello-import.html",
        controller: "TrelloImportCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            onCancel: '&'
        }
    }

TrelloImportDirective.$inject = []

angular.module("taigaProjects").directive("tgTrelloImport", TrelloImportDirective)
