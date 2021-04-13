HomeProjectListDirective = (currentUserService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("recents"))

    directive = {
        templateUrl: "home/projects/home-project-list.html"
        scope: {}
        link: link
    }

    return directive

HomeProjectListDirective.$inject = [
    "tgCurrentUserService"
]

angular.module("taigaHome").directive("tgHomeProjectList", HomeProjectListDirective)
