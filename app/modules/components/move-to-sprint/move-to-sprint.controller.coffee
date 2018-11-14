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
# File: components/move-to-sprint/move-to-sprint-controller.coffee
###

taiga = @.taiga

class MoveToSprintController
    @.$inject = [
      '$scope'
      'tgLightboxFactory'
    ]

    constructor: (@scope, @lightboxFactory) ->
        @.hasOpenItems = false
        @.disabled = false
        @.openItems = {
            uss: []
            tasks: []
            issues: []
        }

        @scope.$watch "vm.uss", () => @getOpenUss()
        @scope.$watch "vm.unnasignedTasks", () => @getOpenUnassignedTasks()
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
        return if !@.uss
        @.openItems.uss = []
        @.uss.map (us) =>
            if us.is_closed is false
                @.openItems.uss.push({
                    us_id: us.id
                    order: us.sprint_order
                })
        @.hasOpenItems = @checkOpenItems()

    getOpenUnassignedTasks: () ->
        return if !@.unnasignedTasks
        @.openItems.tasks = []
        @.unnasignedTasks.map (column) => column.map (task) =>
            if task.get('model').get('is_closed') is false
                @.openItems.tasks.push({
                    task_id: task.get('model').get('id')
                    order: task.get('model').get('taskboard_order')
                })
        @.hasOpenItems = @checkOpenItems()

    getOpenIssues: () ->
        return if !@.issues
        @.openItems.issues = []
        @.issues.map (issue) =>
            if issue.get('status').get('is_closed') is false
                @.openItems.issues.push({ issue_id: issue.get('id') })
        @.hasOpenItems = @checkOpenItems()

angular.module('taigaComponents').controller('MoveToSprintCtrl', MoveToSprintController)
