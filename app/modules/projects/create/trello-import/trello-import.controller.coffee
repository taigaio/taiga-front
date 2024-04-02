###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
