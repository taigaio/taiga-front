taiga = @.taiga

ProjectArchivedWarningDirective = (projectService) ->
    return {
        scope: {},
        controller: "ProjectArchivedWarning",
        controllerAs: "vm",
        templateUrl: "components/project-archived-warning/project-archived-warning.html",
    }

ProjectArchivedWarningDirective.$inject = [
    "tgProjectService",
]

angular.module("taigaComponents").directive("tgProjectArchivedWarning", ProjectArchivedWarningDirective)