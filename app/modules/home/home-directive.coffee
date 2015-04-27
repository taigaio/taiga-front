HomeDirective = ->
    directive = {
        templateUrl: "home/home.html"
        scope: {}
    }

    return directive

angular.module("taigaProjects").directive("tgHome", HomeDirective)
