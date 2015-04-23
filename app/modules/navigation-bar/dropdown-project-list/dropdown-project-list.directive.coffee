DropdownProjectListDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        scope.vm.projects = projectsService.projects

    directive = {
        templateUrl: "navigation-bar/dropdown-project-list/dropdown-project-list.html"
        scope: {}
        link: link
    }

    return directive


angular.module("taigaNavigationBar").directive("tgDropdownProjectList",
    ["tgProjects", DropdownProjectListDirective])
