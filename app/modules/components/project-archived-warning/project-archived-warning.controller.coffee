taiga = @.taiga

class ProjectArchivedWarningController
    @.$inject = [
        "tgProjectService",
    ]

    constructor: (@projectService) ->
        @.isArchived = @projectService.isArchived() ? null


angular.module("taigaComponents").controller("ProjectArchivedWarning", ProjectArchivedWarningController)