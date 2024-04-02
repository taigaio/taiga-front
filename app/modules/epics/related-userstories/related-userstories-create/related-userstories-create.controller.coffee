###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module("taigaEpics")

class RelatedUserstoriesCreateController
    @.$inject = [
        "tgCurrentUserService",
        "tgResources",
        "$tgConfirm",
        "$tgAnalytics"
    ]

    constructor: (@currentUserService, @rs, @confirm, @analytics) ->
        @.projects = null
        @.projectUserstories = Immutable.List()
        @.loading = false

    loadProjects: () ->
        if @.projects == null
            @.projects = @currentUserService.projects.get("unblocked")

    filterUss: (selectedProjectId, filterText) ->
        promise = @rs.userstories.listInAllProjects({project: selectedProjectId, q: filterText}, true).then (data) =>
            excludeIds = @.epicUserstories.map((us) -> us.get('id'))
            filteredData = data.filter((us) -> excludeIds.indexOf(us.get('id')) == -1)
            @.projectUserstories = filteredData
        promise

    saveRelatedUserStory: (selectedUserstoryId, onSavedRelatedUserstory) ->
        # This method assumes the following methods are binded to the controller:
        # - validateExistingUserstoryForm
        # - setExistingUserstoryFormErrors
        # - loadRelatedUserstories
        return if not @.validateExistingUserstoryForm()

        @.loading = true

        onError = (data) =>
            @.loading = false
            @confirm.notify("error")
            @.setExistingUserstoryFormErrors(data)

        onSuccess = () =>
            @analytics.trackEvent("epic related user story", "create", "create related user story on epic", 1)
            @.loading = false
            if onSavedRelatedUserstory
                onSavedRelatedUserstory()
            @.loadRelatedUserstories()

        epicId = @.epic.get('id')
        @rs.epics.addRelatedUserstory(epicId, selectedUserstoryId).then(onSuccess, onError)

    bulkCreateRelatedUserStories: (selectedProjectId, userstoriesText, onCreatedRelatedUserstory) ->
        # This method assumes the following methods are binded to the controller:
        # - validateNewUserstoryForm
        # - setNewUserstoryFormErrors
        # - loadRelatedUserstories
        return if not @.validateNewUserstoryForm()

        @.loading = true

        onError = (data) =>
            @.loading = false
            @confirm.notify("error")
            @.setNewUserstoryFormErrors(data)

        onSuccess = () =>
            @analytics.trackEvent("epic related user story", "create", "create related user story on epic", 1)
            @.loading = false
            if onCreatedRelatedUserstory
                onCreatedRelatedUserstory()
            @.loadRelatedUserstories()

        epicId = @.epic.get('id')
        @rs.epics.bulkCreateRelatedUserStories(epicId, selectedProjectId, userstoriesText).then(onSuccess, onError)


module.controller("RelatedUserstoriesCreateCtrl", RelatedUserstoriesCreateController)
