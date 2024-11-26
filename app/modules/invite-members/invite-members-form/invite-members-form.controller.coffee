###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga


class InviteMembersFormController
    @.$inject = [
        "tgProjectService",
        "$tgResources",
        "lightboxService",
        "$tgConfirm",
        "$rootScope"
    ]

    constructor: (@projectService, @rs, @lightboxService, @confirm, @rootScope) ->
        @.project = @projectService.project
        @.roles = @projectService.project.get('roles')
        @.rolesValues = {}
        @.loading = false
        @.defaultMaxInvites = 4

    _areRolesValidated: () ->
        Object.defineProperty @, 'areRolesValidated', {
            get: () =>
                roleIds = _.filter _.values(@.rolesValues), (it) -> return it
                return roleIds.length == @.contactsToInvite.size + @.emailsToInvite.size
        }

    _checkLimitMemberships: () ->
        if @.project.get('max_memberships') == null
            @.membersLimit = @.defaultMaxInvites
        else
            pendingMembersCount = Math.max(@.project.get('max_memberships') - @.project.get('total_memberships'), 0)
            @.membersLimit = Math.min(pendingMembersCount, @.defaultMaxInvites)

        @.showWarningMessage = @.membersLimit < @.defaultMaxInvites

    sendInvites: () ->
        @.setInvitedContacts = []
        _.forEach(@.rolesValues, (key, value) =>
            @.setInvitedContacts.push({
                'role_id': key
                'username': value
            })
        )
        @.loading = true
        @rs.memberships.bulkCreateMemberships(
            @.project.get('id'),
            @.setInvitedContacts,
            @.inviteContactsMessage
        )
            .then (response) => # On success
                @projectService.fetchProject().then =>
                    @.loading = false
                    @lightboxService.closeAll()
                    @rootScope.$broadcast("membersform:new:success")
                    @confirm.notify('success')
            .catch (response) => # On error
                @.loading = false
                if response.data._error_message
                    @confirm.notify("error", response.data._error_message)
                else if response.data.__all__
                    @confirm.notify("error", response.data.__all__[0])


angular.module("taigaAdmin").controller("InviteMembersFormCtrl", InviteMembersFormController)
