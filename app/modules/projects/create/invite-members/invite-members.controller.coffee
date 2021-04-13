class InviteMembersController
    @.$inject = []

    isDisabled: (id) ->
        return @.invitedMembers.indexOf(id) == -1

angular.module("taigaProjects").controller("InviteMembersCtrl", InviteMembersController)
