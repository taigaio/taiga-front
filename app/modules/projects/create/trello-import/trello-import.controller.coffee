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
# File: projects/create/trello-import/trello-import.controller.coffee
###

class TrelloImportController
    @.$inject = [
        'tgTrelloImportService',
        '$tgConfirm',
        '$translate',
        'tgImportProjectService',
    ]

    constructor: (@trelloImportService, @confirm, @translate, @importProjectService) ->
        @.project = null
        taiga.defineImmutableProperty @, 'projects', () => return @trelloImportService.projects
        taiga.defineImmutableProperty @, 'members', () => return @trelloImportService.projectUsers

    startProjectSelector: () ->
        @trelloImportService.fetchProjects().then () => @.step = 'project-select-trello'

    onSelectProject: (project) ->
        @.step = 'project-form-trello'
        @.project = project
        @.fetchingUsers = true

        @trelloImportService.fetchUsers(@.project.get('id')).then () => @.fetchingUsers = false

    onSaveProjectDetails: (project) ->
        @.project = project
        @.step = 'project-members-trello'

    onCancelMemberSelection: () ->
        @.step = 'project-form-trello'

    startImport: (users) ->
        loader = @confirm.loader(@translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'), @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'), true)

        loader.start()

        promise = @trelloImportService.importProject(
            @.project.get('name'),
            @.project.get('description'),
            @.project.get('id'),
            users,
            @.project.get('keepExternalReference'),
            @.project.get('is_private')
        )

        @importProjectService.importPromise(promise).then () => loader.stop()

    submitUserSelection: (users) ->
        @.startImport(users)

        return null

angular.module('taigaProjects').controller('TrelloImportCtrl', TrelloImportController)
