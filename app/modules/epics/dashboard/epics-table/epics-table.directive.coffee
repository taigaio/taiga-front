EpicsTableDirective = () ->
    return {
        templateUrl:"epics/dashboard/epics-table/epics-table.html",
        controller: "EpicsTableCtrl",
        controllerAs: "vm",
        scope: {}
    }


angular.module('taigaEpics').directive("tgEpicsTable", EpicsTableDirective)
