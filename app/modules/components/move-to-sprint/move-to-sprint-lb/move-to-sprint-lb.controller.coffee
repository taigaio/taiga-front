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
# File: components/move-to-sprint/move-to-sprint-lb/move-to-sprint-lb.controller.coffee
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
        '$tgConfirm'
    ]

    constructor: (
        @rootScope
        @scope
        @rs
        @projectService
        @translate
        @lightboxService
        @confirm
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
            @.sprints = data.milestones

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
                @rs.userstories.bulkUpdateMilestone(
                    @.projectId
                    @.selectedSprintId
                    @.itemsToMove.uss
                )
            )
        if  @.itemsToMove.tasks
            promises.push(
                @rs.tasks.bulkUpdateMilestone(
                    @.projectId
                    @.selectedSprintId
                    @.itemsToMove.tasks
                )
            )
        if  @.itemsToMove.issues
            promises.push(
                @rs.issues.bulkUpdateMilestone(
                    @.projectId
                    @.selectedSprintId
                    @.itemsToMove.issues
                )
            )
        return Promise.all(promises)

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
