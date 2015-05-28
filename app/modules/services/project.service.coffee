taiga = @.taiga

class ProjectService
    @.$inject = [
        "tgProjectsService"
    ]

    constructor: (@projectsService) ->
        @._project = null
        @._section = null
        @._sectionsBreadcrumb = Immutable.List()

        taiga.defineImmutableProperty @, "project", () => return @._project
        taiga.defineImmutableProperty @, "section", () => return @._section
        taiga.defineImmutableProperty @, "sectionsBreadcrumb", () => return @._sectionsBreadcrumb

    setSection: (section) ->
        @._section = section

        if section
            @._sectionsBreadcrumb = @._sectionsBreadcrumb.push(@._section)
        else
            @._sectionsBreadcrumb = Immutable.List()

    setProject: (pslug) ->
        if @._pslug != pslug
            @._pslug = pslug

            @.fetchProject()

    fetchProject: () ->
        return @projectsService.getProjectBySlug(@._pslug).then (project) =>
            @._project = project

angular.module("taigaCommon").service("tgProjectService", ProjectService)
