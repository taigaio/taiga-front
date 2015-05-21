class ProfilePageController extends taiga.Controller
    @.$inject = [
        "$appTitle",
        "$tgAuth",
        "$routeParams"
    ]

    constructor: (@appTitle, @auth, @routeParams) ->
        if @routeParams.slug
            @.user = @auth.userData
        else
            @.user = @auth.userData

        @appTitle.set(@.user.get('username'))

angular.module("taigaProfile").controller("Profile", ProfilePageController)
