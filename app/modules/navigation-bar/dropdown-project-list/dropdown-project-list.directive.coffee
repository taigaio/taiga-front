DropdownProjectListDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> projectsService.currentUserProjects.get("recents"))

        scope.vm.newProject = ->
            projectsService.newProject()

    directive = {
        templateUrl: "navigation-bar/dropdown-project-list/dropdown-project-list.html"
        scope: {}
        link: link
    }

    return directive

DropdownProjectListDirective.$inject = [
    "tgProjectsService"
]

angular.module("taigaNavigationBar").directive("tgDropdownProjectList", DropdownProjectListDirective)
