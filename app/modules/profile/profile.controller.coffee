class ProfilePageController extends taiga.Controller
    @.$inject = [
        "$appTitle",
        "$tgAuth"
    ]

    constructor: (@appTitle, @auth) ->
        user = @auth.getUser()

        @appTitle.set(user.username)

angular.module("taigaProfile").controller("Profile", ProfilePageController)
