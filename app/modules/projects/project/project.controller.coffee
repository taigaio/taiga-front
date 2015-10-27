class ProjectController
    @.$inject = [
        "$routeParams",
        "tgAppMetaService",
        "$tgAuth",
        "$translate",
        "tgProjectService"
    ]

    constructor: (@routeParams, @appMetaService, @auth, @translate, @projectService) ->
        projectSlug = @routeParams.pslug
        @.user = @auth.userData

        taiga.defineImmutableProperty @, "project", () => return @projectService.project
        taiga.defineImmutableProperty @, "members", () => return @projectService.activeMembers

        @appMetaService.setfn @._setMeta.bind(this)

    _setMeta: (project)->
        metas = {}

        return metas if !@.project

        ctx = {projectName: @.project.get("name")}

        metas.title = @translate.instant("PROJECT.PAGE_TITLE", ctx)
        metas.description = @.project.get("description")

        return metas

angular.module("taigaProjects").controller("Project", ProjectController)
