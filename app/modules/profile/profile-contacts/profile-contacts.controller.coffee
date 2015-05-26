class ProfileContactsController
    @.$inject = [
        "tgUserService"
    ]

    constructor: (@userService) ->

    loadContacts: () ->
        @userService.getContacts(@.userId)
            .then (contacts) =>
                @.contacts = contacts

angular.module("taigaProfile")
    .controller("ProfileContacts", ProfileContactsController)
