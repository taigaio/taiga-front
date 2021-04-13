CantOwnProjectExplanationDirective = () ->
    return {
        templateUrl: "projects/transfer/cant-own-project-explanation.html"
    }

angular.module("taigaProjects").directive("tgCantOwnProjectExplanation", CantOwnProjectExplanationDirective)
