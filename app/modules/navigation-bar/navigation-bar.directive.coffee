NavigationBarDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> projectsService.currentUserProjects.get("recents"))

    directive = {
        templateUrl: "navigation-bar/navigation-bar.html"
        scope: {}
        link: link
    }

    return directive

NavigationBarDirective.$inject = [
    "tgProjectsService"
]

angular.module("taigaNavigationBar").directive("tgNavigationBar", NavigationBarDirective)
