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
# File: modules/taskboard/taskboard-tasks.coffee
###

groupBy = @.taiga.groupBy

class TaskboardTasksService extends taiga.Service
    @.$inject = []
    constructor: () ->
        @.reset()

    reset: () ->
        @.tasksRaw = []
        @.foldStatusChanged = {}
        @.usTasks = Immutable.Map()

    init: (project, usersById) ->
        @.project = project
        @.usersById = usersById

    resetFolds: () ->
        @.foldStatusChanged = {}
        @.refresh()

    toggleFold: (taskId) ->
        @.foldStatusChanged[taskId] = !@.foldStatusChanged[taskId]
        @.refresh()

    add: (task) ->
        @.tasksRaw = @.tasksRaw.concat(task)
        @.refresh()

    set: (tasks) ->
        @.tasksRaw = tasks
        @.refreshRawOrder()
        @.refresh()

    setUserstories: (userstories) ->
        @.userstories = userstories

    refreshRawOrder: () ->
        @.order = {}

        @.order[task.id] = task.taskboard_order for task in @.tasksRaw

    assignOrders: (order) ->
        order = _.invert(order)
        @.order = _.assign(@.order, order)

        @.refresh()

    getTask: (id) ->
        findedTask = null

        @.usTasks.forEach (us) ->
            us.forEach (status) ->
                findedTask = status.find (task) -> return task.get('id') == id

                return false if findedTask

            return false if findedTask

        return findedTask

    replace: (task) ->
        @.usTasks = @.usTasks.map (us) ->
            return us.map (status) ->
                findedIndex = status.findIndex (usItem) ->
                    return usItem.get('id') == us.get('id')

                if findedIndex != -1
                    status = status.set(findedIndex, task)

                return status

    getTaskModel: (id) ->
        return _.find @.tasksRaw, (task) -> return task.id == id

    replaceModel: (task) ->
        @.tasksRaw = _.map @.tasksRaw, (it) ->
            if task.id == it.id
                return task
            else
                return it

        @.refresh()

    move: (id, usId, statusId, index) ->
        task = @.getTaskModel(id)

        taskByUsStatus = _.filter @.tasksRaw, (task) =>
            return task.status == statusId && task.user_story == usId

        taskByUsStatus = _.sortBy taskByUsStatus, (it) => @.order[it.id]

        taksWithoutMoved = _.filter taskByUsStatus, (it) => it.id != id
        beforeDestination = _.slice(taksWithoutMoved, 0, index)
        afterDestination = _.slice(taksWithoutMoved, index)

        setOrders = {}

        previous = beforeDestination[beforeDestination.length - 1]

        previousWithTheSameOrder = _.filter beforeDestination, (it) =>
            @.order[it.id] == @.order[previous.id]

        if previousWithTheSameOrder.length > 1
            for it in previousWithTheSameOrder
                setOrders[it.id] = @.order[it.id]

        if !previous
            @.order[task.id] = 0
        else if previous
            @.order[task.id] = @.order[previous.id] + 1

        for it, key in afterDestination
            @.order[it.id] = @.order[task.id] + key + 1

        task.status = statusId
        task.user_story = usId
        task.taskboard_order = @.order[task.id]

        @.refresh()

        return {"task_id": task.id, "order": @.order[task.id], "set_orders": setOrders}

    refresh: ->
        if !@.project
            return

        @.tasksRaw = _.sortBy @.tasksRaw, (it) => @.order[it.id]

        tasks = @.tasksRaw
        taskStatusList = _.sortBy(@.project.task_statuses, "order")

        usTasks = {}

        # Iterate over all userstories and
        # null userstory for unassigned tasks
        for us in _.union(@.userstories, [{id:null}])
            usTasks[us.id] = {}
            for status in taskStatusList
                usTasks[us.id][status.id] = []

        for taskModel in tasks
            if usTasks[taskModel.user_story]? and usTasks[taskModel.user_story][taskModel.status]?
                task = {}

                model = taskModel.getAttrs()

                task.foldStatusChanged = @.foldStatusChanged[taskModel.id]
                task.model = model
                task.images = _.filter model.attachments, (it) -> return !!it.thumbnail_card_url
                task.id = taskModel.id
                task.assigned_to = @.usersById[taskModel.assigned_to]
                task.colorized_tags = _.map task.model.tags, (tag) =>
                    return {name: tag[0], color: tag[1]}

                usTasks[taskModel.user_story][taskModel.status].push(task)

        @.usTasks = Immutable.fromJS(usTasks)

angular.module("taigaKanban").service("tgTaskboardTasks", TaskboardTasksService)
