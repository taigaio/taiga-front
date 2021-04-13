EpicRowDirective = () ->
    return {
        templateUrl:"epics/dashboard/epic-row/epic-row.html",
        controller: "EpicRowCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            epic: '=',
            options: '='
        }
    }

angular.module('taigaEpics').directive("tgEpicRow", EpicRowDirective)
