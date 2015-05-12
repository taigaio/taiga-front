class ProjectController
    @.$inject = [
        "tgProjectsService",
        "$routeParams",
        "$appTitle"
    ]

    constructor: (@projectsService, @routeParams, @appTitle) ->
        projectSlug = @routeParams.pslug

        @projectsService.getProjectBySlug(projectSlug)
            .then (project) =>
                @appTitle.set(project.get("name"))

                @.project = project

angular.module("taigaProjects").controller("Project", ProjectController)
