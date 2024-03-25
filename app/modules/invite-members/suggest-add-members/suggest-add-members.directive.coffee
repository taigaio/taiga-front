###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
