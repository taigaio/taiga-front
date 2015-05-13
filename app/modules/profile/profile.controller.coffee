class ProfilePageController extends taiga.Controller
    @.$inject = [
        "$appTitle",
        "$tgAuth"
    ]

    constructor: (@appTitle, @auth) ->
        @.user = @auth.userData

        @appTitle.set(@.user.get('username'))

angular.module("taigaProfile").controller("Profile", ProfilePageController)
