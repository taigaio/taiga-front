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
