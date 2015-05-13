class PageController extends taiga.Controller
    @.$inject = [
        "$appTitle",
        "$translate",
        "pageParams"
    ]

    constructor: (@appTitle, @translate, @pageParams) ->
        if @pageParams.title
            @translate(@pageParams.title).then (text) => @appTitle.set(text)

angular.module("taigaPage").controller("Page", PageController)
