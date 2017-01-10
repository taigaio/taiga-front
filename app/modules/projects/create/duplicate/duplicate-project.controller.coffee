###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: project.controller.coffee
###

class DuplicateProjectController
    @.$inject = [
        "tgCurrentUserService",
        "tgProjectsService",
        "$tgLocation",
        "$tgNavUrls"
    ]

    constructor: (@currentUserService, @projectsService, @location, @urlservice) ->
        allProjects = @currentUserService.projects.get("all")
        @.projects = allProjects.filter (project) =>
            !project.get('blocked_code')
        @.user = @currentUserService.getUser()
        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()
        @.duplicatedProject = {}

    getReferenceProject: (slug) ->
        @projectsService.getProjectBySlug(slug).then (project) =>
            @.referenceProject = project
            @.invitedMembers = project.get('members')
            @._getInvitedMembers(@.invitedMembers)

    _getInvitedMembers: (members) ->
        @.invitedMembers = members
        @.invitedMembers = @.invitedMembers.filter (members) =>
            members.get('id') != @.user.get('id')
        @.setInvitedMembers(@.invitedMembers)
        @.checkUsersLimit(@.invitedMembers)

    setInvitedMembers: (members) ->
        @.duplicatedProject.users = members.map (member) =>
            member.get('id')
        @.checkUsersLimit(members)

    checkUsersLimit: (members) ->
        size = members.size
        @.limitMembersPrivateProject = undefined
        @.limitMembersPublicProject = undefined
        if @.duplicatedProject.is_private
            @.limitMembersPublicProject = false
            @.limitMembersPrivateProject = @.user.get('max_memberships_private_projects') < size
        else if !@.duplicatedProject.is_private && @.user.get('max_memberships_public_projects')
            @.limitMembersPrivateProject = false
            @.limitMembersPublicProject = @.user.get('max_memberships_public_projects') < size


    onDuplicateProject: () ->
        projectId = @.referenceProject.get('id')
        data = @.duplicatedProject
        @.loading = true
        @projectsService.duplicate(projectId, data).then (newProject) =>
            @.loading = false
            @location.path(@urlservice.resolve("project", {project: newProject.data.slug}))
            @currentUserService.loadProjects()

angular.module("taigaProjects").controller("DuplicateProjectCtrl", DuplicateProjectController)
