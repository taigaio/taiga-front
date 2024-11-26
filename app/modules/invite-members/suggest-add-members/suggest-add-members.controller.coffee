###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
