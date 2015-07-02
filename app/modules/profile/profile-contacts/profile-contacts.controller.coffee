class ProfileContactsController
    @.$inject = [
        "tgUserService",
        "tgCurrentUserService"
    ]

    constructor: (@userService, @currentUserService) ->
        @.currentUser = @currentUserService.getUser()

        @.isCurrentUser = false

        if @.currentUser && @.currentUser.get("id") == @.user.get("id")
            @.isCurrentUser = true

    loadContacts: () ->
        @userService.getContacts(@.user.get("id"))
            .then (contacts) =>
                @.contacts = contacts

angular.module("taigaProfile")
    .controller("ProfileContacts", ProfileContactsController)
