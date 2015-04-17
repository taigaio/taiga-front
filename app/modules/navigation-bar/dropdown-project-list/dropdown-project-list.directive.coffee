DropdownProjectListDirective = () ->
    directive = {
        templateUrl: "navigation-bar/dropdown-project-list/dropdown-project-list.html"
        controller: "ProjectsController"
        scope: {}
        bindToController: true
        controllerAs: "vm"
    }

    return directive


angular.module("taigaNavigationBar").directive("tgDropdownProjectList",
    DropdownProjectListDirective)
