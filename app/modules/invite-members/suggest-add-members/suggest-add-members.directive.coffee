###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

SuggestAddMembersDirective = (lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.$watch "vm.contacts", (contacts) =>
            if contacts
                ctrl.filterContacts()

    return {
        scope: {},
        templateUrl:"invite-members/suggest-add-members/suggest-add-members.html",
        controller: "SuggestAddMembersCtrl",
        controllerAs: "vm",
        bindToController: {
            contacts: '=',
            onInviteSuggested: '&',
            onInviteEmail: '&'
        },
        link: link
    }

angular.module("taigaAdmin").directive("tgSuggestAddMembers", ["lightboxService", SuggestAddMembersDirective])
