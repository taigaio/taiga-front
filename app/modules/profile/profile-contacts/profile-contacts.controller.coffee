class ProfileContactsController
    @.$inject = [
        "tgUserService",
        "tgCurrentUserService"
    ]

    constructor: (@userService, @currentUserService) ->

    loadContacts: () ->
        @.currentUser = @currentUserService.getUser()

        @.isCurrentUser = false

        if @.currentUser.get("id") == @.user.get("id")
            @.isCurrentUser = true

        @userService.getContacts(@.user.get("id"))
            .then (contacts) =>
                @.contacts = contacts

angular.module("taigaProfile")
    .controller("ProfileContacts", ProfileContactsController)
