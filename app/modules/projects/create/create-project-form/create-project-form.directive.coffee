CreateProjectFormDirective = () ->
    return {
        templateUrl:"projects/create/create-project-form/create-project-form.html",
        controller: "CreateProjectFormCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            type: '@'
        }
    }

angular.module("taigaProjects").directive("tgCreateProjectForm", CreateProjectFormDirective)
