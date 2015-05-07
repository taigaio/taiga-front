HomeProjectListDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> projectsService.currentUserProjects.get("recents"))

        scope.vm.newProject = ->
            projectsService.newProject()

    directive = {
        templateUrl: "home/projects/home-project-list.html"
        scope: {}
        link: link
    }

    return directive

HomeProjectListDirective.$inject = ["tgProjectsService"]

angular.module("taigaHome").directive("tgHomeProjectList", HomeProjectListDirective)
