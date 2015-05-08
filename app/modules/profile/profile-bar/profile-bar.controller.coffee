class ProfileBarController
    @.$inject = [
        "$tgAuth"
    ]

    constructor: (@auth) ->
        @.user =  @auth.getUser()

angular.module("taigaProfile").controller("ProfileBar", ProfileBarController)
