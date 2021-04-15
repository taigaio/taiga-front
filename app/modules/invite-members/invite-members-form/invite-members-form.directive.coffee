###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
