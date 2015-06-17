class ProjectController
    @.$inject = [
        "tgProjectsService",
        "$routeParams",
        "tgAppMetaService",
        "$tgAuth",
        "tgXhrErrorService",
        "$translate"
    ]

    constructor: (@projectsService, @routeParams, @appMetaService, @auth, @xhrError, @translate) ->
        projectSlug = @routeParams.pslug
        @.user = @auth.userData

        @projectsService
            .getProjectBySlug(projectSlug)
            .then (project) =>
                @.project = project
                @._setMeta(@.project)

            .catch (xhr) =>
                @xhrError.response(xhr)

    _setMeta: (project)->
        ctx = {projectName: project.get("name")}

        title = @translate.instant("PROJECT.PAGE_TITLE", ctx)
        description = project.get("description")
        @appMetaService.setAll(title, description)

angular.module("taigaProjects").controller("Project", ProjectController)
