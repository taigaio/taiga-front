###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

InviteMembersDirective = () ->
    link = (scope, el, attr, ctrl) ->

    return {
        link: link,
        templateUrl:"projects/create/invite-members/invite-members.html",
        controller: "InviteMembersCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            invitedMembers: '<',
            members: '<',
            onToggleInvitedMember: '&'
        }
    }

InviteMembersDirective.$inject = []

angular.module("taigaProjects").directive("tgInviteMembers", InviteMembersDirective)
