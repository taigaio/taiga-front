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
# File: projects/create/jira-import/jira-import-project-form/jira-import-project-form.controller.coffee
###

class JiraImportProjectFormController
    @.$inject = [
        "tgCurrentUserService"
    ]

    constructor: (@currentUserService) ->
        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        @.projectForm = @.project.toJS()

        @.projectForm.is_private = false
        @.projectForm.keepExternalReference = false
        if @.projectForm.importer_type == "agile"
            @.projectForm.project_type = null
        else
            @.projectForm.project_type = "scrum"
        @.projectForm.create_subissues = true

        if !@.canCreatePublicProjects.valid && @.canCreatePrivateProjects.valid
            @.projectForm.is_private = true

    checkUsersLimit: () ->
        @.limitMembersPrivateProject = @currentUserService.canAddMembersPrivateProject(@.members.size)
        @.limitMembersPublicProject = @currentUserService.canAddMembersPublicProject(@.members.size)

    saveForm: () ->
        @.onSaveProjectDetails({project: Immutable.fromJS(@.projectForm)})

    canCreateProject: () ->
        if @.projectForm.is_private
            return @.canCreatePrivateProjects.valid
        else
            return @.canCreatePublicProjects.valid

    isDisabled: () ->
        return !@.canCreateProject()

angular.module('taigaProjects').controller('JiraImportProjectFormCtrl', JiraImportProjectFormController)
