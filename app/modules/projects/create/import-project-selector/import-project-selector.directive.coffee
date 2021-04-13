ImportProjectSelectorDirective = () ->
    return {
        templateUrl:"projects/create/import-project-selector/import-project-selector.html",
        controller: "ImportProjectSelectorCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            projects: '<',
            onCancel: '&',
            onSelectProject: '&',
            logo: '@',
            noProjectsMsg: '@',
            search: '@'
        }
    }

angular.module("taigaProjects").directive("tgImportProjectSelector", ImportProjectSelectorDirective)
