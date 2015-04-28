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
        "tgHomeService",
        "$translate"

    ]

    constructor: (@scope, @q, @rs, @rootscope, @navUrls, @auth, @location,
        @appTitle, @projectUrl, @config, tgLoader, @projectsService, @homeService,
        @translate) ->
        @appTitle.set(@translate.instant("PROJECT.WELCOME"))

        if !@auth.isAuthenticated()
            @location.path(@navUrls.resolve("login"))

        #Projects
        projectsPromise = @projectsService.fetchProjects()

        #In progress work
        user = @auth.getUser()
        workInProgressPromise = @homeService.fetchWorkInProgress(user.id)

        # Finally
        @q.all([projectsPromise, workInProgressPromise]).finally tgLoader.pageLoaded


angular.module("taigaHome").controller("HomePage", ProjectsPageController)
