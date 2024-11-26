###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class CardController
    @.$inject = [
        "$scope",
    ]

    constructor: (@scope) ->

    getLinkParams: () ->
        ctrl = taiga.findScope @scope, (scope) ->
            if scope && scope.ctrl
                return scope.ctrl

            return false

        lastLoadUserstoriesParams = ctrl.lastLoadUserstoriesParams

        if lastLoadUserstoriesParams
            lastLoadUserstoriesParams['status'] = @scope.vm.item.getIn(['model', 'status'])
            lastLoadUserstoriesParams['swimlane'] = @scope.vm.item.getIn(['model', 'swimlane'])

            lastLoadUserstoriesParams = _.pickBy(lastLoadUserstoriesParams, _.identity)

            if ctrl.scope.swimlanesList.size && !lastLoadUserstoriesParams['swimlane']
                lastLoadUserstoriesParams.swimlane = "null"

            ParsedLastLoadUserstoriesParams = {}
            Object.keys(lastLoadUserstoriesParams).forEach (key) ->
                ParsedLastLoadUserstoriesParams['kanban-' + key] = lastLoadUserstoriesParams[key]

            return ParsedLastLoadUserstoriesParams
        else
            return {}

    visible: (name) ->
        return @.zoom.indexOf(name) != -1

    hasTasks: () ->
        tasks = @.item.getIn(['model', 'tasks'])
        return tasks and tasks.size > 0

    getTagColor: (color) ->
        if color
            return color
        return "#A9AABC"

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

        if !_.isUndefined(@.item.get('foldStatusChanged')) && @.visible('unfold')
            # by default attachments & task are folded in level 2, see also card-unfold.jadee
            if @.zoomLevel == 2
                visibility.related = @.item.get('foldStatusChanged')
                visibility.slides = @.item.get('foldStatusChanged')
            else
                visibility.related = !@.item.get('foldStatusChanged')
                visibility.slides = !@.item.get('foldStatusChanged')

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
