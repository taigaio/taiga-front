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

        if !@auth.isAuthenticated()
            @location.path(@navUrls.resolve("login"))

        @appTitle.set(@translate.instant("PROJECT.SECTION_PROJECTS"))

angular.module("taigaProjects").controller("ProjectsPage", ProjectsPageController)
