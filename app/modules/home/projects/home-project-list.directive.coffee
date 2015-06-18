HomeProjectListDirective = (currentUserService, projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("recents"))

        scope.vm.newProject = ->
            projectsService.newProject()

    directive = {
        templateUrl: "home/projects/home-project-list.html"
        scope: {}
        link: link
    }

    return directive

HomeProjectListDirective.$inject = [
    "tgCurrentUserService",
    "tgProjectsService"
]

angular.module("taigaHome").directive("tgHomeProjectList", HomeProjectListDirective)
