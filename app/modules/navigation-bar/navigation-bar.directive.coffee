NavigationBarDirective = () ->
    directive = {
        templateUrl: "navigation-bar/navigation-bar.html"
    }

    return directive


angular.module("taigaNavigationBar").directive("tgNavigationBar",
    NavigationBarDirective)
