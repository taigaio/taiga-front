###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: kanban-userstories.service.coffee
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

    init: (project, usersById) ->
        @.project = project
        @.usersById = usersById

    resetFolds: () ->
        @.foldStatusChanged = {}
        @.refresh()

    toggleFold: (usId) ->
        @.foldStatusChanged[usId] = !@.foldStatusChanged[usId]
        @.refresh()

    set: (userstories) ->
        @.userstoriesRaw = userstories
        @.refreshRawOrder()
        @.refresh()

    add: (us) ->
        @.userstoriesRaw = @.userstoriesRaw.concat(us)
        @.refreshRawOrder()
        @.refresh()

    addArchivedStatus: (statusId) ->
        @.archivedStatus.push(statusId)

    isUsInArchivedHiddenStatus: (usId) ->
        us = @.getUsModel(usId)

        return @.archivedStatus.indexOf(us.status) != -1 &&
            @.statusHide.indexOf(us.status) != -1

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

    move: (id, statusId, index) ->
        us = @.getUsModel(id)

        usByStatus = _.filter @.userstoriesRaw, (it) =>
            return it.status == statusId

        usByStatus = _.sortBy usByStatus, (it) => @.order[it.id]

        usByStatusWithoutMoved = _.filter usByStatus, (it) => it.id != id
        beforeDestination = _.slice(usByStatusWithoutMoved, 0, index)
        afterDestination = _.slice(usByStatusWithoutMoved, index)

        setOrders = {}

        previous = beforeDestination[beforeDestination.length - 1]

        previousWithTheSameOrder = _.filter beforeDestination, (it) =>
            @.order[it.id] == @.order[previous.id]

        if previousWithTheSameOrder.length > 1
            for it in previousWithTheSameOrder
                setOrders[it.id] = @.order[it.id]

        if !previous and (!afterDestination or afterDestination.length == 0)
            @.order[us.id] = 0
        else if !previous and afterDestination and afterDestination.length > 0
            @.order[us.id] = @.order[afterDestination[0].id] - 1
        else if previous
            @.order[us.id] = @.order[previous.id] + 1

        for it, key in afterDestination
            @.order[it.id] = @.order[us.id] + key + 1

        us.status = statusId
        us.kanban_order = @.order[us.id]

        @.refresh()

        return {"us_id": us.id, "order": @.order[us.id], "set_orders": setOrders}

    moveToEnd: (id, statusId) ->
        us = @.getUsModel(id)

        @.order[us.id] = -1

        us.status = statusId
        us.kanban_order = @.order[us.id]

        @.refresh()

        return {"us_id": us.id, "order": -1}

    replace: (us) ->
        @.usByStatus = @.usByStatus.map (status) ->
            findedIndex = status.findIndex (usItem) ->
                return usItem.get('id') == us.get('id')

            if findedIndex != -1
                status = status.set(findedIndex, us)

            return status

    replaceModel: (us) ->
        @.userstoriesRaw = _.map @.userstoriesRaw, (usItem) ->
            if us.id == usItem.id
                return us
            else
                return usItem

        @.refresh()

    getUs: (id) ->
        findedUs = null

        @.usByStatus.forEach (status) ->
            findedUs = status.find (us) -> return us.get('id') == id

            return false if findedUs

        return findedUs

    getUsModel: (id) ->
        return _.find @.userstoriesRaw, (us) -> return us.id == id

    refresh: ->
        @.userstoriesRaw = _.sortBy @.userstoriesRaw, (it) => @.order[it.id]

        userstories = @.userstoriesRaw
        userstories = _.map userstories, (usModel) =>
            us = {}

            model = usModel.getAttrs()

            us.foldStatusChanged = @.foldStatusChanged[usModel.id]

            us.model = model
            us.images = _.filter model.attachments, (it) -> return !!it.thumbnail_card_url

            us.id = usModel.id
            us.assigned_to = @.usersById[usModel.assigned_to]
            us.colorized_tags = _.map us.model.tags, (tag) =>
                return {name: tag[0], color: tag[1]}

            return us

        usByStatus = _.groupBy userstories, (us) ->
            return us.model.status

        @.usByStatus = Immutable.fromJS(usByStatus)

angular.module("taigaKanban").service("tgKanbanUserstories", KanbanUserstoriesService)
