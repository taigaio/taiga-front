class ProfileContactsController
    @.$inject = [
        "tgResources",
        "$tgAuth"
    ]

    constructor: (@rs, @auth) ->

    loadContacts: () ->
        userId = @auth.getUser().id

        @rs.users.getContacts(userId)
            .then (contacts) =>
                @.contacts = contacts

angular.module("taigaProfile")
    .controller("ProfileContacts", ProfileContactsController)
