class ProjectsPageController extends taiga.Controller
    @.$inject = [
        "$scope",
        "$q",
        "$tgResources",
        "$rootScope",
        "$tgNavUrls",
        "$tgAuth",
        "$tgLocation",
        "$appTitle",
        "$projectUrl",
        "$tgConfig",
        "tgLoader",
        "tgProjectsService",
        "$translate"
    ]

    constructor: (@scope, @q, @rs, @rootscope, @navUrls, @auth, @location,
        @appTitle, @projectUrl, @config, tgLoader, @projectsService, @translate) ->
        @appTitle.set(@translate.instant("PROJECT.SECTION_PROJECTS"))

        if !@auth.isAuthenticated()
            @location.path(@navUrls.resolve("login"))

        #Projects
        promise = @projectsService.fetchProjects()

        # Finally
        promise.finally tgLoader.pageLoaded


angular.module("taigaProjects").controller("ProjectsPage", ProjectsPageController)
