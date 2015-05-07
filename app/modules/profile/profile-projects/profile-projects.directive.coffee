ProfileProjectsDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        taiga.defineImmutableProperty(scope.vm, "projects", () -> projectsService.currentUserProjects.get("all"))

    directive = {
        templateUrl: "profile/profile-projects/profile-projects.html"
        scope: {}
        link: link
    }

    return directive


ProfileProjectsDirective.$inject = ["tgProjectsService"]

angular.module("taigaProfile").directive("tgProfileProjects", ProfileProjectsDirective)
