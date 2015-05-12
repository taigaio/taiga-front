ProjectDirective = () ->
    return {
        templateUrl: "projects/project/project.html",
        controllerAs: "vm",
        controller: "Project"
    }

angular.module("taigaProjects").directive("tgProject", ProjectDirective)
