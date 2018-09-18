###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: invite-members/invite-members-form/invite-members-form.controller.coffee
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
                roleIds = _.filter Object.values(@.rolesValues), (it) -> return it
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


angular.module("taigaAdmin").controller("InviteMembersFormCtrl", InviteMembersFormController)
