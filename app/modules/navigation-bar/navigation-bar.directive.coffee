NavigationBarDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> projectsService.projects.get("recents"))

    directive = {
        templateUrl: "navigation-bar/navigation-bar.html"
        scope: {}
        link: link
    }

    return directive


angular.module("taigaNavigationBar").directive("tgNavigationBar",
    ["tgProjectsService", NavigationBarDirective])
