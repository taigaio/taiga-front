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

        if !@auth.isAuthenticated()
            @location.path(@navUrls.resolve("login"))

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set(@translate.instant("PROJECT.WELCOME"))

        # Finally
        promise.finally tgLoader.pageLoaded

    loadInitialData: ->
        user = @auth.getUser()
        #Projects
        promise = @projectsService.fetchProjects()
        return promise.then () =>
            #In progress work
            return @homeService.fetchWorkInProgress(user.id)

angular.module("taigaHome").controller("HomePage", ProjectsPageController)
