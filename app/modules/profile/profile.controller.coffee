class ProfileController
    @.$inject = [
        "tgAppMetaService",
        "tgCurrentUserService",
        "$routeParams",
        "tgUserService",
        "tgXhrErrorService",
        "$translate"
    ]

    constructor: (@appMetaService, @currentUserService, @routeParams, @userService, @xhrError, @translate) ->
        @.isCurrentUser = false

        if @routeParams.slug
            @userService
                .getUserByUserName(@routeParams.slug)
                .then (user) =>
                    if !user.get('is_active')
                        @xhrError.notFound()
                    else
                        @.user = user
                        @.isCurrentUser = false
                        @._setMeta(@.user)

                        return user
                .catch (xhr) =>
                    return @xhrError.response(xhr)

        else
            @.user = @currentUserService.getUser()
            @.isCurrentUser = true
            @._setMeta(@.user)

    _setMeta: (user) ->
        ctx = {
            userFullName: user.get("full_name_display"),
            userUsername: user.get("username")
        }

        @translate("USER.PROFILE.PAGE_TITLE", ctx).then (title) =>
            description = user.get("bio")
            @appMetaService.setAll(title, description)

angular.module("taigaProfile").controller("Profile", ProfileController)
