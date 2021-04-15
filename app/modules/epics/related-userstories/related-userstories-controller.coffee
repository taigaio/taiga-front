###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaEpics")

class RelatedUserStoriesController
    @.$inject = [
        "tgProjectService",
        "tgEpicsService"
    ]

    constructor: (@projectService, @epicsService) ->
        @.sectionName = "Epics"
        @.showCreateRelatedUserstoriesLightbox = false

    showRelatedUserStoriesSection: () ->
        return @projectService.hasPermission("view_epics") or @.userstories?.length > 0

    userCanSort: () ->
        return @projectService.hasPermission("modify_epic")

    loadRelatedUserstories: () ->
        @epicsService.listRelatedUserStories(@.epic)
            .then (userstories) =>
                @.userstories = userstories

    reorderRelatedUserstory: (us, newIndex) ->
        @epicsService.reorderRelatedUserstory(@.epic, @.userstories, us, newIndex)
            .then (userstories) =>
                @.userstories = userstories

module.controller("RelatedUserStoriesCtrl", RelatedUserStoriesController)
