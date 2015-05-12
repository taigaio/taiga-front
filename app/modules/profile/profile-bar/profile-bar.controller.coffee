class ProfileBarController
    @.$inject = [
        "$tgAuth",
        "tgUserService"
    ]

    constructor: (@auth, @userService) ->
        @.user =  @auth.getUser()

        @.loadStats()

    loadStats: () ->
        return @userService.getStats(@.user.id).then (stats) =>
            @.stats = stats

angular.module("taigaProfile").controller("ProfileBar", ProfileBarController)
