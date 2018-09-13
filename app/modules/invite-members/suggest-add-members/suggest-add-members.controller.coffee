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
# File: invite-members/suggest-add-members/suggest-add-members.controller.coffee
###

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
