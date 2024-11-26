###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

class MoveToSprintController
    @.$inject = [
      '$scope'
      'tgLightboxFactory'
      'tgProjectService'
    ]

    constructor: (
        @scope
        @lightboxFactory
        @projectService
    ) ->
        @.permissions = @projectService.project.get('my_permissions')
        @.hasOpenItems = false
        @.disabled = false
        @.openItems = {
            uss: []
            tasks: []
            issues: []
        }

        @scope.$watch "vm.uss", () => @getOpenUss()
        @scope.$watch "vm.unnasignedTasks", () => @getOpenStorylessTasks()
        @scope.$watch "vm.issues", () => @getOpenIssues()

    checkOpenItems: () ->
        return _.some(Object.keys(@.openItems), (x) => @.openItems[x].length > 0)

    openLightbox: () ->
        if @.disabled is not true && @.hasOpenItems
            openItems = {}
            _.map @.openItems, (itemsList, itemsType) ->
                if itemsList.length
                    openItems[itemsType] = itemsList

            @lightboxFactory.create('tg-lb-move-to-sprint', {
                "class": "lightbox lightbox-move-to-sprint"
                "sprint": "sprint"
                "open-items": "openItems"
            }, {
                sprint: @.sprint
                openItems: openItems
            })

    getOpenUss: () ->
        return if !@.uss or @.permissions.indexOf("modify_us") == -1
        @.openItems.uss = []
        @.uss.map (us) =>
            if us.is_closed is false
                @.openItems.uss.push({
                    us_id: us.id
                    order: us.sprint_order
                })
        @.hasOpenItems = @checkOpenItems()

    getOpenStorylessTasks: () ->
        return if !@.unnasignedTasks or @.permissions.indexOf("modify_task") == -1
        @.openItems.tasks = []
        @.unnasignedTasks.map (column) => column.map (taskId) =>
            task = @.taskMap.get(taskId)
            if task.get('model').get('is_closed') is false
                @.openItems.tasks.push({
                    task_id: task.get('model').get('id')
                    order: task.get('model').get('taskboard_order')
                })
        @.hasOpenItems = @checkOpenItems()

    getOpenIssues: () ->
        return if !@.issues or @.permissions.indexOf("modify_issue") == -1
        @.openItems.issues = []
        @.issues.map (issue) =>
            if issue.get('status').get('is_closed') is false
                @.openItems.issues.push({ issue_id: issue.get('id') })
        @.hasOpenItems = @checkOpenItems()

angular.module('taigaComponents').controller('MoveToSprintCtrl', MoveToSprintController)
