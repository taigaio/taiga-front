###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module("taigaComponents")

class MoveToSprintLightboxController
    @.$inject = [
        '$rootScope'
        '$scope'
        '$tgResources'
        'tgProjectService'
        '$translate'
        'lightboxService'
        '$tgConfirm',
        '$q'
    ]

    constructor: (
        @rootScope
        @scope
        @rs
        @projectService
        @translate
        @lightboxService
        @confirm
        @q
    ) ->
        @.projectId = @projectService.project.get('id')
        @.loading = false
        @.someSelected = false
        @.selectedSprintId = null
        @.typesSelected = {
            uss: false
            tasks: false
            issues: false
        }
        @.itemsToMove = {}
        @._loadSprints()

        @scope.$watch "vm.openItems", (openItems) =>
            return if !openItems
            @._init(openItems)

    _init: (openItems) ->
        @.hasManyItemTypes = _.size(@.openItems) > 1

        @.ussCount = parseInt(openItems.uss?.length)
        @.updateSelected('uss', @.ussCount > 0)

        @.tasksCount = parseInt(openItems.tasks?.length)
        @.updateSelected('tasks', @.tasksCount > 0)

        @.issuesCount = parseInt(openItems.issues?.length)
        @.updateSelected('issues', @.issuesCount > 0)

    _loadSprints: () ->
        @rs.sprints.list(@.projectId, {closed: false}).then (data) =>
            @.sprints = _.filter(data.milestones, (x) => x.id != @.sprint.id)

    updateSelected: (itemType, value) ->
        @.typesSelected[itemType] = value
        @.someSelected = _.some(@.typesSelected)

        if value is true
            @.itemsToMove[itemType] = @.openItems[itemType]
        else if @.itemsToMove[itemType]
            delete @.itemsToMove[itemType]

    submit: () ->
        itemsNotMoved = {}
        _.map @.openItems, (itemsList, itemsType) =>
            if not @.itemsToMove[itemsType]
                itemsNotMoved[itemsType] = true

        @.loading = true

        @moveItems().then () =>
            @rootScope.$broadcast("taskboard:items:move", @.typesSelected)
            @lightboxService.closeAll()
            @.loading = false
            if _.size(itemsNotMoved) > 0
                @.displayWarning(itemsNotMoved)

    moveItems: () ->
        promises = []
        if  @.itemsToMove.uss
            promises.push(
                @rs.sprints.moveUserStoriesMilestone(
                    @.sprint.id
                    @.projectId
                    @.selectedSprintId
                    @.itemsToMove.uss
                )
            )
        if  @.itemsToMove.tasks
            promises.push(
                @rs.sprints.moveTasksMilestone(
                    @.sprint.id
                    @.projectId
                    @.selectedSprintId
                    @.itemsToMove.tasks
                )
            )
        if  @.itemsToMove.issues
            promises.push(
                @rs.sprints.moveIssuesMilestone(
                    @.sprint.id
                    @.projectId
                    @.selectedSprintId
                    @.itemsToMove.issues
                )
            )
        return @q.all(promises)

    displayWarning: (itemsNotMoved) ->
        action = @translate.instant('COMMON.I_GET_IT')
        if _.size(itemsNotMoved) == 1 and itemsNotMoved.issues is true
            title = @translate.instant('TASKBOARD.MOVE_TO_SPRINT.WARNING_ISSUES_NOT_MOVED_TITLE')
            desc = @translate.instant('TASKBOARD.MOVE_TO_SPRINT.WARNING_ISSUES_NOT_MOVED')
        else
            totalItemsMoved = 0
            _.map @.itemsToMove, (itemsList, itemsType) -> totalItemsMoved += itemsList.length
            title = @translate.instant(
                'TASKBOARD.MOVE_TO_SPRINT.WARNING_SPRINT_STILL_OPEN_TITLE'
                { total: totalItemsMoved }
                'messageformat'
            )
            desc = @translate.instant(
                'TASKBOARD.MOVE_TO_SPRINT.WARNING_SPRINT_STILL_OPEN'
                { sprintName: @.sprint?.name }
            )
        @confirm.success(title, desc, null, action)

module.controller("MoveToSprintLbCtrl", MoveToSprintLightboxController)
