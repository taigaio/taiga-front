###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
