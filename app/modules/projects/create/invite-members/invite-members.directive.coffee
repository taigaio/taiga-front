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
