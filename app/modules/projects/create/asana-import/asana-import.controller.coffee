###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class AsanaImportController
    @.$inject = [
        'tgAsanaImportService',
        '$tgConfirm',
        '$translate',
        'tgImportProjectService',
    ]

    constructor: (@asanaImportService, @confirm, @translate, @importProjectService) ->
        @.step = 'autorization-asana'
        @.project = null
        taiga.defineImmutableProperty @, 'projects', () => return @asanaImportService.projects
        taiga.defineImmutableProperty @, 'members', () => return @asanaImportService.projectUsers

    startProjectSelector: () ->
        @.step = 'project-select-asana'
        @asanaImportService.fetchProjects()

    onSelectProject: (project) ->
        @.step = 'project-form-asana'
        @.project = project
        @.fetchingUsers = true

        @asanaImportService.fetchUsers(@.project.get('id')).then () => @.fetchingUsers = false

    onSaveProjectDetails: (project) ->
        @.project = project
        @.step = 'project-members-asana'

    onCancelMemberSelection: () ->
        @.step = 'project-form-asana'        

    startImport: (users) ->
        loader = @confirm.loader(@translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'), @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'), true)

        loader.start()

        promise = @asanaImportService.importProject(
            @.project.get('name'),
            @.project.get('description'),
            @.project.get('id'),
            users,
            @.project.get('keepExternalReference'),
            @.project.get('is_private')
            @.project.get('project_type')
        )

        @importProjectService.importPromise(promise).then () => loader.stop()

    submitUserSelection: (users) ->
        @.startImport(users)
        return null

angular.module('taigaProjects').controller('AsanaImportCtrl', AsanaImportController)
