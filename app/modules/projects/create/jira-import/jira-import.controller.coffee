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
# File: projects/create/jira-import/jira-import.controller.coffee
###

class JiraImportController
    @.$inject = [
        'tgJiraImportService',
        '$tgConfirm',
        '$translate',
        'tgImportProjectService',
    ]

    constructor: (@jiraImportService, @confirm, @translate, @importProjectService) ->
        @.step = 'autorization-jira'
        @.project = null
        taiga.defineImmutableProperty @, 'projects', () => return @jiraImportService.projects
        taiga.defineImmutableProperty @, 'members', () => return @jiraImportService.projectUsers

    startProjectSelector: () ->
        @.step = 'project-select-jira'
        @jiraImportService.fetchProjects()

    onSelectProject: (project) ->
        @.step = 'project-form-jira'
        @.project = project
        @.fetchingUsers = true

        @jiraImportService.fetchUsers(@.project.get('id')).then () => @.fetchingUsers = false

    onSaveProjectDetails: (project) ->
        @.project = project
        @.step = 'project-members-jira'

    onCancelMemberSelection: () ->
        @.step = 'project-form-jira'        

    startImport: (users) ->
        loader = @confirm.loader(@translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'), @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'), true)

        loader.start()

        projectType = @.project.get('project_type')
        if projectType == "issues" and @.project.get('create_subissues')
            projectType = "issues-with-subissues"

        promise = @jiraImportService.importProject(
            @.project.get('name'),
            @.project.get('description'),
            @.project.get('id'),
            users,
            @.project.get('keepExternalReference'),
            @.project.get('is_private'),
            projectType,
            @.project.get('importer_type'),
        )

        @importProjectService.importPromise(promise).then () => loader.stop()

    submitUserSelection: (users) ->
        @.startImport(users)
        return null

angular.module('taigaProjects').controller('JiraImportCtrl', JiraImportController)
