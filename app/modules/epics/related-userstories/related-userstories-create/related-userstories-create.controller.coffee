###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: related-userstory-create.controller.coffee
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
