class PageController extends taiga.Controller
    @.$inject = [
        "$tgAuth",
        "$appTitle",
        "$translate",
        "$tgLocation",
        "$tgNavUrls",
        "pageParams"
    ]

    constructor: (@auth, @appTitle, @translate, @location, @navUrls, @pageParams) ->
        if @pageParams.authRequired && !@auth.isAuthenticated()
            @location.path(@navUrls.resolve("login"))

        if @pageParams.title
            @translate(@pageParams.title).then (text) => @appTitle.set(text)

angular.module("taigaPage").controller("Page", PageController)
