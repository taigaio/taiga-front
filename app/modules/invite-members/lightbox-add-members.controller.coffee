###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: invite-members/lightbox-add-members.controller.coffee
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
