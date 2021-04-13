BlockedProjectExplanationDirective = () ->
    return {
        templateUrl: "projects/project/blocked-project-explanation.html"
    }

angular.module("taigaProjects").directive("tgBlockedProjectExplanation", BlockedProjectExplanationDirective)
