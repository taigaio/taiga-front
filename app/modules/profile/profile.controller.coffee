class ProfilePageController
    @.$inject = [
        "$appTitle",
        "tgCurrentUserService",
        "$routeParams",
        "tgUserService",
        "tgXhrErrorService"
    ]

    constructor: (@appTitle, @currentUserService, @routeParams, @userService, @xhrError) ->
        @.isCurrentUser = false

        if @routeParams.slug
            @userService
                .getUserByUserName(@routeParams.slug)
                .then (user) =>
                    @.user = user
                    @.isCurrentUser = false
                    @appTitle.set(@.user.get('full_name'))
                .catch (xhr) =>
                    @xhrError.response(xhr)

        else
            @.user = @currentUserService.getUser()
            @.isCurrentUser = true
            @appTitle.set(@.user.get('full_name_display'))

angular.module("taigaProfile").controller("Profile", ProfilePageController)
