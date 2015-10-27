LikeProjectButtonDirective = ->
    return {
        scope: {}
        controller: "LikeProjectButton",
        bindToController: {
            project: '='
        }
        controllerAs: "vm",
        templateUrl: "projects/components/like-project-button/like-project-button.html",
    }

angular.module("taigaProjects").directive("tgLikeProjectButton", LikeProjectButtonDirective)
