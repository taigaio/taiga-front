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
# File: projects/transfer/transfer-project.controller.coffee
###

module = angular.module('taigaProjects')

class TransferProject
    @.$inject = [
        "$routeParams",
        "tgProjectsService"
        "$location",
        "$tgAuth",
        "tgCurrentUserService",
        "$tgNavUrls",
        "$translate",
        "$tgConfirm",
        "tgErrorHandlingService"
    ]

    constructor: (@routeParams, @projectService, @location, @authService, @currentUserService, @navUrls, @translate, @confirmService, @errorHandlingService) ->

    initialize: () ->
        @.projectId = @.project.get("id")
        @.token = @routeParams.token
        @.showAddComment = false
        return @._refreshUserData()

    _validateToken: () ->
        return @projectService.transferValidateToken(@.projectId, @.token).then null, (data, status) =>
            @errorHandlingService.notfound()

    _refreshUserData: () ->
        return @authService.refresh().then () =>
            @._validateToken()
            @._setProjectData()
            @._checkOwnerData()

    _setProjectData: () ->
        @.canBeOwnedByUser = @currentUserService.canOwnProject(@.project)

    _checkOwnerData: () ->
        currentUser = @currentUserService.getUser()
        if(@.project.get('is_private'))
            @.ownerMessage = 'ADMIN.PROJECT_TRANSFER.OWNER_MESSAGE.PRIVATE'
            @.maxProjects = currentUser.get('max_private_projects')
            if @.maxProjects == null
                @.maxProjects = @translate.instant('ADMIN.PROJECT_TRANSFER.UNLIMITED_PROJECTS')
            @.currentProjects = currentUser.get('total_private_projects')
            maxMemberships = currentUser.get('max_memberships_private_projects')

        else
            @.ownerMessage = 'ADMIN.PROJECT_TRANSFER.OWNER_MESSAGE.PUBLIC'
            @.maxProjects = currentUser.get('max_public_projects')
            if @.maxProjects == null
                @.maxProjects = @translate.instant('ADMIN.PROJECT_TRANSFER.UNLIMITED_PROJECTS')
            @.currentProjects = currentUser.get('total_public_projects')
            maxMemberships = currentUser.get('max_memberships_public_projects')

        @.validNumberOfMemberships = maxMemberships == null || @.project.get('total_memberships') <= maxMemberships

    transferAccept: (token, reason) ->
        @.loadingAccept = true
        return @projectService.transferAccept(@.project.get("id"), token, reason).then () =>
            newUrl = @navUrls.resolve("project-admin-project-profile-details", {
                project: @.project.get("slug")
            })
            @.loadingAccept = false
            @location.path(newUrl)

            @confirmService.notify("success", @translate.instant("ADMIN.PROJECT_TRANSFER.ACCEPTED_PROJECT_OWNERNSHIP"), '', 5000)
            return

    transferReject: (token, reason) ->
        @.loadingReject = true
        return @projectService.transferReject(@.project.get("id"), token, reason).then () =>
            newUrl = @navUrls.resolve("home", {
                project: @project.get("slug")
            })
            @.loadingReject = false
            @location.path(newUrl)
            @confirmService.notify("success", @translate.instant("ADMIN.PROJECT_TRANSFER.REJECTED_PROJECT_OWNERNSHIP"), '', 5000)

            return

    addComment: () ->
        @.showAddComment = true

    hideComment: () ->
        @.showAddComment = false
        @.reason = ''


module.controller("TransferProjectController", TransferProject)
