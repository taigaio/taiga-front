###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
