DropdownProjectListDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        projectsService.projectsSuscription (projects) ->
            scope.vm.projects = projects

        projectsService.getProjects()

    directive = {
        templateUrl: "navigation-bar/dropdown-project-list/dropdown-project-list.html"
        scope: {}
        link: link
    }

    return directive


angular.module("taigaNavigationBar").directive("tgDropdownProjectList",
    ["tgProjects", DropdownProjectListDirective])
