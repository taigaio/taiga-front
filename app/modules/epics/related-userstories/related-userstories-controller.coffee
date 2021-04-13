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
