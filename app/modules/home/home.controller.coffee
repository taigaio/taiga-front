class HomeController
    @.$inject = [
        "tgCurrentUserService",
        "$location",
        "$tgNavUrls"
    ]

    constructor: (@currentUserService, @location, @navUrls) ->
        if not @currentUserService.getUser()
            @location.path(@navUrls.resolve("discover"))


angular.module("taigaHome").controller("Home", HomeController)
