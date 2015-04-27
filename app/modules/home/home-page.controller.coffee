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
        "tgProjects",
        "$translate"

    ]

    constructor: (@scope, @q, @rs, @rootscope, @navUrls, @auth, @location,
        @appTitle, @projectUrl, @config, tgLoader, @projects, @translate) ->
        @appTitle.set(@translate.instant("PROJECT.WELCOME"))

        if !@auth.isAuthenticated()
            @location.path(@navUrls.resolve("login"))

        #Projects
        promise = @projects.fetchProjects()

        # Finally
        promise.finally tgLoader.pageLoaded


angular.module("taigaHome").controller("HomePage", ProjectsPageController)
