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
# File: card.controller.coffee
###

class CardController
    @.$inject = []

    visible: (name) ->
        return @.zoom.indexOf(name) != -1

    hasTasks: () ->
        tasks = @.item.getIn(['model', 'tasks'])
        return tasks and tasks.size > 0

    hasMultipleAssignedUsers: () ->
        assignedUsers = @.item.getIn(['model', 'assigned_users'])
        return assignedUsers and assignedUsers.size > 1

    hasVisibleAttachments: () ->
        return @.item.get('images').size > 0

    toggleFold: () ->
        @.onToggleFold({id: @.item.get('id')})

    getClosedTasks: () ->
        return @.item.getIn(['model', 'tasks']).filter (task) -> return task.get('is_closed')

    closedTasksPercent: () ->
        return @.getClosedTasks().size * 100 / @.item.getIn(['model', 'tasks']).size

    getModifyPermisionKey: () ->
        return  if @.type == 'task' then 'modify_task' else 'modify_us'

    getDeletePermisionKey: () ->
        return  if @.type == 'task' then 'delete_task' else 'delete_us'

    _setVisibility: () ->
        visibility = {
            related: @.visible('related_tasks'),
            slides: @.visible('attachments')
        }

        if!_.isUndefined(@.item.get('foldStatusChanged'))
            if @.visible('related_tasks') && @.visible('attachments')
                visibility.related = !@.item.get('foldStatusChanged')
                visibility.slides = !@.item.get('foldStatusChanged')
            else if @.visible('attachments')
                visibility.related = @.item.get('foldStatusChanged')
                visibility.slides = @.item.get('foldStatusChanged')
            else if !@.visible('related_tasks') && !@.visible('attachments')
                visibility.related = @.item.get('foldStatusChanged')
                visibility.slides = @.item.get('foldStatusChanged')

        if !@.item.getIn(['model', 'tasks']) || !@.item.getIn(['model', 'tasks']).size
            visibility.related = false

        if !@.item.get('images') || !@.item.get('images').size
            visibility.slides = false

        return visibility

    isRelatedTasksVisible: () ->
        visibility = @._setVisibility()

        return visibility.related

    isSlideshowVisible: () ->
        visibility = @._setVisibility()

        return visibility.slides

    getNavKey: () ->
        if @.type == 'task'
            return 'project-tasks-detail'
        else if @.type == 'issue'
            return 'project-issues-detail'
        else
            return 'project-userstories-detail'

angular.module('taigaComponents').controller('Card', CardController)
