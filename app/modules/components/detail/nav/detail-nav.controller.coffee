module = angular.module("taigaBase")

class DetailNavController
    @.$inject = [
        "$tgNavUrls",
    ]

    constructor: (@navUrls) ->
        return

    _checkNav: () ->
        if @.item.neighbors.previous?.ref?
            ctx = {
                project: @.item.project_extra_info.slug
                ref: @.item.neighbors.previous.ref
            }
            @.previousUrl = @navUrls.resolve("project-" + @.item._name + "-detail", ctx)

        if @.item.neighbors.next?.ref?
            ctx = {
                project: @.item.project_extra_info.slug
                ref: @.item.neighbors.next.ref
            }
            @.nextUrl = @navUrls.resolve("project-" + @.item._name + "-detail", ctx)

module.controller("DetailNavCtrl", DetailNavController)
