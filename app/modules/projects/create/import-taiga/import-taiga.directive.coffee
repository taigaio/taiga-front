ImportTaigaDirective = () ->
    return {
        templateUrl:"projects/create/import-taiga/import-taiga.html",
        controller: "ImportTaigaCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {}
    }

angular.module("taigaProjects").directive("tgImportTaiga", ImportTaigaDirective)
