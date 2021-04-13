class ProjectRouterController
    @.$inject = [
        "$routeParams",
        "$location"
        "tgProjectService"
        "$tgResources"
        "$tgSections"
    ]

    constructor: (@routeParams, @location, @projectService, @rs, @tgSections) ->
        @getProjectHomepage()
            .then (section) =>
                if section
                    @location.url("project/#{@routeParams.pslug}/#{section}")
                else
                    @gotoDefaultProjectHomepage()
            .then null, ->
                @gotoDefaultProjectHomepage()

    gotoDefaultProjectHomepage: () ->
        @location.url("project/#{@routeParams.pslug}/timeline")

    getProjectHomepage: () ->
        project = @projectService.project.toJS()

        @rs.userProjectSettings.list({project: project.id}).then (userProjectSettings) =>
            settings = _.find(userProjectSettings, {"project": project.id})
            return if !settings

            return @tgSections.getPath(project.slug, settings.homepage)

angular.module("taigaProjects").controller("ProjectRouter", ProjectRouterController)
