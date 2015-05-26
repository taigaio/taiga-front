class ProfilePageController extends taiga.Controller
    @.$inject = [
        "$appTitle",
        "tgCurrentUserService",
        "$routeParams",
        "tgUserService"
    ]

    constructor: (@appTitle, @currentUserService, @routeParams, @userService) ->
        if @routeParams.slug
            @userService
                .getUserByUserName(@routeParams.slug)
                .then (user) =>
                    @.user = user
                    @.isCurrentUser = false
                    @appTitle.set(@.user.get('username'))
        else
            @.user = @currentUserService.getUser()
            @.isCurrentUser = true
            @appTitle.set(@.user.get('username'))

angular.module("taigaProfile").controller("Profile", ProfilePageController)
