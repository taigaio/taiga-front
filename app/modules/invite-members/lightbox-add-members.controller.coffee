###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
