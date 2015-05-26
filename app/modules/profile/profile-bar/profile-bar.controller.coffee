class ProfileBarController
    @.$inject = [
        "tgUserService"
    ]

    constructor: (@userService) ->
        @.loadStats()

    loadStats: () ->
        return @userService.getStats(@.user.get("id")).then (stats) =>
            @.stats = stats

angular.module("taigaProfile").controller("ProfileBar", ProfileBarController)
