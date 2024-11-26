###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

class AddMembersController
    @.$inject = [
        "tgUserService",
        "tgCurrentUserService",
        "tgProjectService",
    ]

    constructor: (@userService, @currentUserService, @projectService) ->
        @.contactsToInvite = Immutable.List()
        @.emailsToInvite = Immutable.List()
        @.contacts = Immutable.List()
        @.displayContactList = false

    _getContacts: () ->
        userId = @currentUserService.getUser().get("id")
        excludeProjectId = @projectService.project.get("id")

        @userService.getContacts(userId, excludeProjectId).then (contacts) =>
            @.contacts = contacts

    _filterContacts: (invited) ->
        @.contacts = @.contacts.filter( (contact) =>
            contact.get('id') != invited.get('id')
        )

    inviteSuggested: (contact) ->
        @.contactsToInvite = @.contactsToInvite.push(contact)
        @._filterContacts(contact)
        @.displayContactList = true

    removeContact: (invited) ->
        @.contactsToInvite = @.contactsToInvite.filter( (contact) =>
            return contact.get('id') != invited.id
        )
        invited = Immutable.fromJS(invited)
        @.contacts = @.contacts.push(invited)
        @.testEmptyContacts()

    inviteEmail: (email) ->
        emailData = Immutable.Map({'email': email})
        @.emailsToInvite = @.emailsToInvite.push(emailData)
        @.displayContactList = true

    removeEmail: (invited) ->
        @.emailsToInvite = @.emailsToInvite.filter( (email) =>
            return email.get('email') != invited.email
        )
        @.testEmptyContacts()

    testEmptyContacts: () ->
        if @.emailsToInvite.size + @.contactsToInvite.size == 0
            @.displayContactList = false

angular.module("taigaAdmin").controller("AddMembersCtrl", AddMembersController)
