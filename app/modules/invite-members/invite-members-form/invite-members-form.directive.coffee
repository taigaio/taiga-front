###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

InviteMembersFormDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl._areRolesValidated()
        ctrl._checkLimitMemberships()

    return {
        scope: {},
        templateUrl:"invite-members/invite-members-form/invite-members-form.html",
        controller: "InviteMembersFormCtrl",
        controllerAs: "vm",
        bindToController: {
            contactsToInvite: '<',
            emailsToInvite: '=',
            onDisplayContactList: '&',
            onRemoveInvitedContact: '&',
            onRemoveInvitedEmail: '&',
            onSendInvites: '&'
        },
        link: link
    }

angular.module("taigaAdmin").directive("tgInviteMembersForm", InviteMembersFormDirective)
