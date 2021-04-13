ImportProjectDirective = () ->

    link = (scope, el, attr, ctrl) ->
        ctrl.start()

    return {
        link: link,
        templateUrl:"projects/create/import/import-project.html",
        controller: "ImportProjectCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            onCancelImport: '&'
        }
    }

ImportProjectDirective.$inject = []

angular.module("taigaProjects").directive("tgImportProject", ImportProjectDirective)
