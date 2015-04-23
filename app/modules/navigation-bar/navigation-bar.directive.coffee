NavigationBarDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        scope.vm.projects = projectsService.projects

    directive = {
        templateUrl: "navigation-bar/navigation-bar.html"
        scope: {}
        link: link
    }

    return directive


angular.module("taigaNavigationBar").directive("tgNavigationBar",
    ["tgProjects", NavigationBarDirective])
