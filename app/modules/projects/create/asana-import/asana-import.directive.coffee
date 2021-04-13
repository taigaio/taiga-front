AsanaImportDirective = () ->
    return {
        link: (scope, elm, attrs, ctrl) ->
            ctrl.startProjectSelector()
        templateUrl:"projects/create/asana-import/asana-import.html",
        controller: "AsanaImportCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            onCancel: '&'
        }
    }

AsanaImportDirective.$inject = []

angular.module("taigaProjects").directive("tgAsanaImport", AsanaImportDirective)
