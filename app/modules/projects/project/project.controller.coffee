class ProjectController
    @.$inject = [
        "tgProjectsService",
        "$routeParams",
        "$appTitle",
        "$tgAuth",
        "tgXhrErrorService"
    ]

    constructor: (@projectsService, @routeParams, @appTitle, @auth, @xhrError) ->
        projectSlug = @routeParams.pslug
        @.user = @auth.userData

        @projectsService
            .getProjectBySlug(projectSlug)
            .then (project) =>
                @appTitle.set(project.get("name"))

                @.project = project
            .catch (xhr) =>
                @xhrError.response(xhr)

angular.module("taigaProjects").controller("Project", ProjectController)
