class ProjectController
    @.$inject = [
        "tgProjectsService",
        "$routeParams",
        "$appTitle",
        "$tgAuth"
    ]

    constructor: (@projectsService, @routeParams, @appTitle, @auth) ->
        projectSlug = @routeParams.pslug
        @.user = @auth.userData

        @projectsService.getProjectBySlug(projectSlug)
            .then (project) =>
                @appTitle.set(project.get("name"))

                @.project = project

angular.module("taigaProjects").controller("Project", ProjectController)
