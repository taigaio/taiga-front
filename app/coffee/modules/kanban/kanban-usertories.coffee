###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

groupBy = @.taiga.groupBy

class KanbanUserstoriesService extends taiga.Service
    @.$inject = [
        "$translate"
    ]

    constructor: (@translate) ->
        @.reset()

    reset: (resetSwimlanesList = true, resetArchivedStatus = true, resetHideStatud = true) ->
        @.userstoriesRaw = []
        @.swimlanes = []
        @.foldStatusChanged = {}
        @.usByStatus = Immutable.Map()
        @.usMap = Immutable.Map()
        @.usByStatusSwimlanes = Immutable.Map()

        if resetHideStatud
            @.statusHide = []

        if resetArchivedStatus
            @.archivedStatus = []

        if resetSwimlanesList
            @.swimlanesList = Immutable.List()

    init: (project, swimlanes, usersById) ->
        @.project = project
        @.swimlanes = swimlanes
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

    initUsByStatusList: (userstories) ->
        for key, usModel of userstories
            status = String(usModel.status)

            if (!@.usByStatus.has(status))
                @.usByStatus = @.usByStatus.set(status, Immutable.List())

    remove: (usModel) ->
        @.userstoriesRaw = @.userstoriesRaw.filter (it) => it.id != usModel.id

        delete @.order[usModel.id]

        status = String(usModel.status)

        @.usMap = @.usMap.delete(usModel.id)

        @.usByStatus = @.usByStatus.set(
            status,
            @.usByStatus.get(status)
            .filter((id) => id != usModel.id)
        )

        @.refreshSwimlanes()

    # don't call refresh to prevent unnecessary mutations in every single us
    add: (usList) ->
        if !Array.isArray(usList)
            usList = [usList]

        usList = _.sortBy usList, ['kanban_order']

        @.userstoriesRaw = @.userstoriesRaw.filter (us) =>
            return !usList.find (it) => it.id == us.id
        @.userstoriesRaw = @.userstoriesRaw.concat(usList)
        @.userstoriesRaw = @.userstoriesRaw.map (us) =>
            return us

        @.refreshRawOrder()

        @.userstoriesRaw = _.sortBy @.userstoriesRaw, [(it) => @.order[it.id]]

        for key, usModel of usList
            us = @.retrieveUserStoryData(usModel)
            status = String(usModel.status)

            if (!@.usByStatus.has(status))
                @.usByStatus = @.usByStatus.set(status, Immutable.List())

            if !@.usMap.get(usModel.id)
                @.usMap = @.usMap.set(usModel.id, Immutable.fromJS(us))

                @.usByStatus = @.usByStatus.set(
                    status,
                    @.usByStatus.get(status)
                    .filter((id) => id != usModel.id)
                    .push(usModel.id)
                )

        @.refreshSwimlanes()

    addArchivedStatus: (statusId) ->
        @.archivedStatus.push(statusId)

    isUsInArchivedHiddenStatus: (usId) ->
        # us = @.getUsModel(usId)
        us = @.usMap.get(usId)
        status = us?.getIn(['model', 'status'])
        return @.archivedStatus.indexOf(status) != -1 &&
            @.statusHide.indexOf(status) != -1

    hideStatus: (statusId) ->
        @.deleteStatus(statusId)
        @.statusHide.push(statusId)

    showStatus: (statusId) ->
        _.remove @.statusHide, (it) -> return it == statusId

    getStatus: (statusId, swimlaneId) ->
        return _.filter @.userstoriesRaw, (it) =>
            return it.status == statusId && (!swimlaneId || it.swimlane == swimlaneId)

    deleteStatus: (statusId) ->
        toDelete = _.filter @.userstoriesRaw, (us) -> return us.status == statusId
        toDelete = _.map (it) -> return it.id

        @.archived = _.difference(@.archived, toDelete)

    refreshRawOrder: () ->
        @.order = {}
        if (@.userstoriesRaw)
            @.order[it.id] = it.kanban_order for it in @.userstoriesRaw

    assignOrders: (order) ->
        @.order = _.assign(@.order, order)

        @.refresh(false)

    move: (usList, statusId, swimlaneId, index, previousCard, nextCard) ->
        usByStatus = @.getStatus(statusId, swimlaneId)
        usByStatus = _.sortBy usByStatus, [(it) => @.order[it.id]]

        if previousCard
            previousUsOrder = @.order[previousCard] + 1
            previousUsIndex = (usByStatus.findIndex (it) => it.id == previousCard) + 1
        else
            previousUsOrder = 0
            previousUsIndex = 0

        usByStatusWithoutMoved = _.filter usByStatus, (listIt) ->
            return !_.find usList, (moveIt) -> return listIt.id == moveIt

        afterDestination = _.slice(usByStatusWithoutMoved, previousUsIndex)

        initialLength = usList.length + 1

        for usModel, key in afterDestination # increase position of the us after the dragged us's
            @.order[usModel.id] = previousUsOrder + initialLength + key

        for usId, key in usList
            usModel = @.getUsModel(usId)
            usModel.status = statusId

            usModel.swimlane = swimlaneId

            @.order[usModel.id] = previousUsOrder + key

            us = @.retrieveUserStoryData(usModel)
            @.usMap = @.usMap.set(us.id, Immutable.fromJS(us))

        @.refresh(false)

        return {
            statusId: statusId,
            swimlaneId: swimlaneId,
            afterUserstoryId: previousCard,
            beforeUserstoryId: nextCard,
            bulkUserstories: usList,
        }

    moveToEnd: (id, statusId) ->
        us = @.getUsModel(id)

        @.order[us.id] = -1

        us.status = statusId
        us.kanban_order = @.order[us.id]

        @.refresh(false)

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
        us.swimlane = usModel.swimlane
        us.assigned_to = @.usersById[usModel.assigned_to]
        us.assigned_users = []

        usModel.assigned_users.forEach (assignedUserId) =>
            assignedUserData = @.usersById[assignedUserId]
            if assignedUserData
                us.assigned_users.push(assignedUserData)

        us.assigned_users_preview = us.assigned_users.slice(0, 3)

        us.colorized_tags = _.map us.model.tags, (tag) =>
            return {name: tag[0], color: tag[1]}

        return us

    refresh: (refreshUsMap = true, refreshSwimlanes = true) ->
        @.userstoriesRaw = _.sortBy @.userstoriesRaw, [(it) => @.order[it.id]]

        collection = {}

        for key, usModel of @.userstoriesRaw
            us = @.retrieveUserStoryData(usModel)
            if (!collection[usModel.status])
                collection[usModel.status] = []

            collection[usModel.status] = collection[usModel.status]
            .filter((id) => id != usModel.id)

            collection[usModel.status].push(usModel.id)

            if refreshUsMap
                @.usMap = @.usMap.set(usModel.id, Immutable.fromJS(us))

        @.usByStatus = Immutable.fromJS(collection)

        if refreshSwimlanes
            @.refreshSwimlanes()

    refreshSwimlanes: () ->
        if !@.swimlanes || !@.swimlanes.length
            return

        @.swimlanesList = Immutable.List()
        @.usByStatusSwimlanes = Immutable.Map()

        userstoriesNoSwimlane = @.userstoriesRaw.filter (us) =>
            return us.swimlane == null

        emptySwimlaneExists = @.swimlanesList.filter (swimlane) =>
            return swimlane.id == null

        if userstoriesNoSwimlane.length && !emptySwimlaneExists.size
            @.swimlanes.forEach (swimlane) =>
                if (!@.swimlanesList.includes(swimlane))
                    @.swimlanesList = @.swimlanesList.push(swimlane)

            emptySwimlane = {
                id: -1,
                kanban_order: 1,
                name: @translate.instant("KANBAN.UNCLASSIFIED_USER_STORIES")
            }
            @.swimlanesList = @.swimlanesList.insert(0, emptySwimlane)

        else
            @.swimlanes.forEach (swimlane) =>
                if (!@.swimlanesList.includes(swimlane))
                    @.swimlanesList = @.swimlanesList.push(swimlane)

        @.swimlanesList.forEach (swimlane) =>
            swimlaneUsByStatus = Immutable.Map()
            @.usByStatus.forEach (usList, statusId) =>
                usListSwimlanes = usList.filter (usId) =>
                    us = @.usMap.get(usId)
                    swimlaneId = if swimlane.id == -1 then null else swimlane.id
                    return us.getIn(['model', 'swimlane']) == swimlaneId

                swimlaneUsByStatus = swimlaneUsByStatus.set(Number(statusId), usListSwimlanes)

            @.usByStatusSwimlanes = @.usByStatusSwimlanes.set(swimlane.id, swimlaneUsByStatus)

angular.module("taigaKanban").service("tgKanbanUserstories", KanbanUserstoriesService)
