NavigationBarDirective = (currentUserService, navigationBarService, $location) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        scope.$on "$routeChangeSuccess", () ->
            if $location.path() == "/"
                scope.vm.active = true
            else
                scope.vm.active = false

        taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("recents"))
        taiga.defineImmutableProperty(scope.vm, "isAuthenticated", () -> currentUserService.isAuthenticated())
        taiga.defineImmutableProperty(scope.vm, "isEnabledHeader", () -> navigationBarService.isEnabledHeader())


    directive = {
        templateUrl: "navigation-bar/navigation-bar.html"
        scope: {}
        link: link
    }

    return directive

NavigationBarDirective.$inject = [
    "tgCurrentUserService",
    "tgNavigationBarService"
    "$location"
]

angular.module("taigaNavigationBar").directive("tgNavigationBar", NavigationBarDirective)
