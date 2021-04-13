taiga = @.taiga

class SuggestAddMembersController
    @.$inject = []

    constructor: () ->
        @.contactQuery = ""

    isEmail: () ->
        return taiga.isEmail(@.contactQuery)

    filterContacts: () ->
        @.filteredContacts = @.contacts.filter( (contact) =>
            contact.get('full_name_display').toLowerCase().includes(@.contactQuery.toLowerCase()) || contact.get('username').toLowerCase().includes(@.contactQuery.toLowerCase());
        ).slice(0,12)

    setInvited: (contact) ->
        @.onInviteSuggested({'contact': contact})

angular.module("taigaAdmin").controller("SuggestAddMembersCtrl", SuggestAddMembersController)
