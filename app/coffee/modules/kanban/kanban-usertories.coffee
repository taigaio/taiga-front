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
# File: modules/kanban/kanban-usertories.coffee
###

groupBy = @.taiga.groupBy

class KanbanUserstoriesService extends taiga.Service
    @.$inject = []

    constructor: () ->
        @.reset()

    reset: () ->
        @.userstoriesRaw = []
        @.archivedStatus = []
        @.statusHide = []
        @.foldStatusChanged = {}
        @.usByStatus = Immutable.Map()
        @.usMap = Immutable.Map()
        @.usByStatusSwimlanes = Immutable.Map()

    init: (project, usersById) ->
        @.project = project
        @.usersById = usersById

    resetFolds: () ->
        @.foldStatusChanged = {}

    toggleFold: (usId) ->
        @.foldStatusChanged[usId] = !@.foldStatusChanged[usId]
        @.refreshUserStory(usId)

    set: (userstories) ->
        @.userstoriesRaw = userstories
        @.refreshRawOrder()
        @.refresh()

    # don't call refresh to prevent unnecessary mutations in every single us
    add: (usList) ->
        if !Array.isArray(usList)
            usList = [usList]

        @.userstoriesRaw = @.userstoriesRaw.concat(usList)
        @.refreshRawOrder()

        @.userstoriesRaw = _.sortBy @.userstoriesRaw, (it) => @.order[it.id]

        for key, usModel of usList
            us = @.retrieveUserStoryData(usModel)
            status = String(usModel.status)

            if (!@.usByStatus.has(status))
                @.usByStatus = @.usByStatus.set(status, Immutable.List())

            if !@.usMap.get(usModel.id)
                @.usMap = @.usMap.set(usModel.id, Immutable.fromJS(us))

                @.usByStatus = @.usByStatus.set(
                    status,
                    @.usByStatus.get(status).push(usModel.id)
                )

        @.refreshSwimlanes()

    addArchivedStatus: (statusId) ->
        @.archivedStatus.push(statusId)

    isUsInArchivedHiddenStatus: (usId) ->
        us = @.getUsModel(usId)
        return @.archivedStatus.indexOf(us?.status) != -1 &&
            @.statusHide.indexOf(us?.status) != -1

    hideStatus: (statusId) ->
        @.deleteStatus(statusId)
        @.statusHide.push(statusId)

    showStatus: (statusId) ->
        _.remove @.statusHide, (it) -> return it == statusId

    getStatus: (statusId) ->
        return _.filter @.userstoriesRaw, (us) -> return us.status == statusId

    deleteStatus: (statusId) ->
        toDelete = _.filter @.userstoriesRaw, (us) -> return us.status == statusId
        toDelete = _.map (it) -> return it.id

        @.archived = _.difference(@.archived, toDelete)

        @.userstoriesRaw = _.filter @.userstoriesRaw, (us) -> return us.status != statusId

        @.refresh()

    refreshRawOrder: () ->
        @.order = {}

        @.order[it.id] = it.kanban_order for it in @.userstoriesRaw

    assignOrders: (order) ->
        @.order = _.assign(@.order, order)

        @.refresh()

    move: (usList, statusId, index) ->

        initialLength = usList.length

        usByStatus = _.filter @.userstoriesRaw, (it) =>
            return it.status == statusId

        usByStatus = _.sortBy usByStatus, (it) => @.order[it.id]

        usByStatusWithoutMoved = _.filter usByStatus, (listIt) ->
            return !_.find usList, (moveIt) -> return listIt.id == moveIt.id

        beforeDestination = _.slice(usByStatusWithoutMoved, 0, index)
        afterDestination = _.slice(usByStatusWithoutMoved, index)

        setOrders = {}

        previous = beforeDestination[beforeDestination.length - 1]

        previousWithTheSameOrder = _.filter beforeDestination, (it) =>
            @.order[it.id] == @.order[previous.id]


        if previousWithTheSameOrder.length > 1
            for it in previousWithTheSameOrder
                setOrders[it.id] = @.order[it.id]

        modifiedUs = []
        setPreviousOrders = []
        setNextOrders = []

        isArchivedHiddenStatus = @.archivedStatus.indexOf(statusId) != -1 &&
            @.statusHide.indexOf(statusId) != -1

        if isArchivedHiddenStatus
            startIndex = new Date().getTime()

        else if !previous
            startIndex = 0

            for it, key in afterDestination # increase position of the us after the dragged us's
                @.order[it.id] = key + initialLength + 1
                it.kanban_order = @.order[it.id]

            setNextOrders = _.map(afterDestination, (it) =>
                {us_id: it.id, order: @.order[it.id]}
            )

        else if previous
            startIndex = @.order[previous.id] + 1

            previousWithTheSameOrder = _.filter(beforeDestination, (it) =>
                it.kanban_order == @.order[previous.id]
            )
            for it, key in afterDestination # increase position of the us after the dragged us's
                @.order[it.id] = @.order[previous.id] + key + initialLength + 1
                it.kanban_order = @.order[it.id]

            setNextOrders = _.map(afterDestination, (it) =>
                {us_id: it.id, order: @.order[it.id]}
            )

            # we must send the USs previous to the dropped USs to tell the backend
            # which USs are before the dropped USs, if they have the same value to
            # order, the backend doens't know after which one do you want to drop
            # the USs
            if previousWithTheSameOrder.length > 1
                setPreviousOrders = _.map(previousWithTheSameOrder, (it) =>
                    {us_id: it.id, order: @.order[it.id]}
                )

        for us, key in usList
            us.status = statusId
            us.kanban_order = startIndex + key
            @.order[us.id] = us.kanban_order

            modifiedUs.push({us_id: us.id, order: us.kanban_order})

        @.refresh()

        return {
            bulkOrders: modifiedUs.concat(setPreviousOrders, setNextOrders),
            usList: modifiedUs,
            set_orders: setOrders
        }

    moveToEnd: (id, statusId) ->
        us = @.getUsModel(id)

        @.order[us.id] = -1

        us.status = statusId
        us.kanban_order = @.order[us.id]

        @.refresh()

        return {"us_id": us.id, "order": -1}

    replace: (us) ->
        @.usMap = @.usMap.set(us.get('id'), us)

    replaceModel: (usModel) ->
        @.userstoriesRaw = _.map @.userstoriesRaw, (usItem) ->
            if usModel.id == usItem.id
                return usModel
            else
                return usItem

        us = @.retrieveUserStoryData(usModel)
        @.usMap = @.usMap.set(usModel.id, Immutable.fromJS(us))

    getUs: (id) ->
        return @.usMap.get(id)

    getUsModel: (id) ->
        return _.find @.userstoriesRaw, (us) -> return us.id == id

    refreshUserStory: (usId) ->
        usModel = @.getUsModel(usId)
        us = @.retrieveUserStoryData(usModel)
        @.usMap = @.usMap.set(usId, Immutable.fromJS(us))

    retrieveUserStoryData: (usModel) ->
        us = {}
        model = usModel.getAttrs()

        us.foldStatusChanged = @.foldStatusChanged[usModel.id]

        us.model = model
        us.images = _.filter model.attachments, (it) -> return !!it.thumbnail_card_url

        us.id = usModel.id
        us.assigned_to = @.usersById[usModel.assigned_to]
        us.assigned_users = []

        usModel.assigned_users.forEach (assignedUserId) =>
            assignedUserData = @.usersById[assignedUserId]
            us.assigned_users.push(assignedUserData)

        us.assigned_users_preview = us.assigned_users.slice(0, 3)

        us.colorized_tags = _.map us.model.tags, (tag) =>
            return {name: tag[0], color: tag[1]}

        return us

    refresh: () ->
        @.userstoriesRaw = _.sortBy @.userstoriesRaw, (it) => @.order[it.id]

        collection = {}

        for key, usModel of @.userstoriesRaw
            us = @.retrieveUserStoryData(usModel)
            if (!collection[usModel.status])
                collection[usModel.status] = []

            collection[usModel.status].push(usModel.id)
            @.usMap = @.usMap.set(usModel.id, Immutable.fromJS(us))

        @.usByStatus = Immutable.fromJS(collection)

        @.refreshSwimlanes()

    refreshSwimlanes: () ->
        if !@.project.swimlanes
            return

        @.usByStatusSwimlanes = Immutable.Map()

        @.project.swimlanes.forEach (swimlane) =>
            swimlaneUsByStatus = Immutable.Map()

            @.usByStatus.forEach (usList, statusId) =>
                usListSwimlanes = usList.filter (usId) =>
                    us = @.usMap.get(usId)
                    return us.getIn(['model', 'swimlane']) == swimlane.id
                swimlaneUsByStatus = swimlaneUsByStatus.set(Number(statusId), usListSwimlanes)

            @.usByStatusSwimlanes = @.usByStatusSwimlanes.set(swimlane.id, swimlaneUsByStatus)

angular.module("taigaKanban").service("tgKanbanUserstories", KanbanUserstoriesService)
