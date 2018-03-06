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
# File: epics.service.coffee
###

taiga = @.taiga

class EpicsService
    @.$inject = [
        'tgProjectService',
        'tgAttachmentsService'
        'tgResources',
        'tgXhrErrorService'
    ]

    constructor: (@projectService, @attachmentsService, @resources, @xhrError) ->
        @.clear()

        taiga.defineImmutableProperty @, 'epics', () => return @._epics

    clear: () ->
        @._loadingEpics = false
        @._disablePagination = false
        @._page = 1
        @._epics = Immutable.List()

    fetchEpics: (reset = false) ->
        @._loadingEpics = true
        @._disablePagination = true

        return @resources.epics.list(@projectService.project.get('id'), @._page)
            .then (result) =>
                if reset
                    @.clear()
                    @._epics = result.list
                else
                    @._epics = @._epics.concat(result.list)

                @._loadingEpics = false

                @._disablePagination = !result.headers('x-pagination-next')
            .catch (xhr) =>
                @xhrError.response(xhr)

    nextPage: () ->
        @._page++

        @.fetchEpics()

    listRelatedUserStories: (epic) ->
        return @resources.userstories.listInEpic(epic.get('id'))

    createEpic: (epicData, attachments, projectId) ->
        if projectId
            epicData.project = projectId
        else
            epicData.project = @projectService.project.get('id')

        return @resources.epics.post(epicData)
            .then (epic) =>
                if !attachments
                    return epic
                else
                    promises = _.map attachments.toJS(), (attachment) =>
                        @attachmentsService.upload(
                            attachment.file, epic.get('id'), epic.get('project'), 'epic')

                    Promise.all(promises).then(@.fetchEpics.bind(this, true))


    reorderEpic: (epic, newIndex) ->
        orderList = {}
        @._epics.forEach (it) ->
            orderList[it.get('id')] = it.get('epics_order')

        withoutMoved = @.epics.filter (it) => it.get('id') != epic.get('id')
        beforeDestination = withoutMoved.slice(0, newIndex)
        afterDestination = withoutMoved.slice(newIndex)

        previous = beforeDestination.last()
        newOrder = if !previous then 0 else previous.get('epics_order') + 1

        orderList[epic.get('id')] = newOrder

        previousWithTheSameOrder = beforeDestination.filter (it) =>
            it.get('epics_order') == previous.get('epics_order')

        setOrders = _.fromPairs previousWithTheSameOrder.map((it) =>
            [it.get('id'), it.get('epics_order')]
        ).toJS()

        afterDestination.forEach (it) -> orderList[it.get('id')] = it.get('epics_order') + 1

        @._epics = @._epics.map (it) -> it.set('epics_order', orderList[it.get('id')])
        @._epics = @._epics.sortBy (it) -> it.get('epics_order')

        data = {
            epics_order: newOrder,
            version: epic.get('version')
        }

        return @resources.epics.reorder(epic.get('id'), data, setOrders).then (newEpic) =>
            @._epics = @._epics.map (it) ->
                if it.get('id') == newEpic.get('id')
                    return newEpic

                return it

    reorderRelatedUserstory: (epic, epicUserstories, userstory, newIndex) ->
        withoutMoved = epicUserstories.filter (it) => it.get('id') != userstory.get('id')
        beforeDestination = withoutMoved.slice(0, newIndex)

        previous = beforeDestination.last()
        newOrder = if !previous then 0 else previous.get('epic_order') + 1

        previousWithTheSameOrder = beforeDestination.filter (it) =>
            it.get('epic_order') == previous.get('epic_order')
        setOrders = _.fromPairs previousWithTheSameOrder.map((it) =>
            [it.get('id'), it.get('epic_order')]
        ).toJS()

        data = {
            order: newOrder
        }
        epicId = epic.get('id')
        userstoryId = userstory.get('id')
        return @resources.epics.reorderRelatedUserstory(epicId, userstoryId, data, setOrders)
            .then () =>
                return @.listRelatedUserStories(epic)

    replaceEpic: (epic) ->
        @._epics = @._epics.map (it) ->
            if it.get('id') == epic.get('id')
                return epic

            return it

    updateEpicStatus: (epic, statusId) ->
        data = {
            status: statusId,
            version: epic.get('version')
        }

        return @resources.epics.patch(epic.get('id'), data)
            .then(@.replaceEpic.bind(this))

    updateEpicAssignedTo: (epic, userId) ->
        data = {
            assigned_to: userId,
            version: epic.get('version')
        }

        return @resources.epics.patch(epic.get('id'), data)
            .then(@.replaceEpic.bind(this))

angular.module('taigaEpics').service('tgEpicsService', EpicsService)
