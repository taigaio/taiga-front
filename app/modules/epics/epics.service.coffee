###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
        'tgXhrErrorService',
        '$q'
    ]

    constructor: (@projectService, @attachmentsService, @resources, @xhrError, @q) ->
        @._epics = Immutable.List()
        taiga.defineImmutableProperty @, 'epics', () => return @._epics

    clear: () ->
        @._epics = Immutable.List()

    fetchEpics: () ->
        return @resources.epics.list(@projectService.project.get('id'))
            .then (epics) =>
                @._epics = epics
            .catch (xhr) =>
                @xhrError.response(xhr)

    listRelatedUserStories: (epic) ->
        return @resources.userstories.listInEpic(epic.get('id'))

    createEpic: (epicData, attachments) ->
        epicData.project = @projectService.project.get('id')

        return @resources.epics.post(epicData)
            .then (epic) =>
                promises = _.map attachments.toJS(), (attachment) =>
                    @attachmentsService.upload(attachment.file, epic.get('id'), epic.get('project'), 'epic')
                @q.all(promises).then () =>
                    @.fetchEpics()

    reorderEpic: (epic, newIndex) ->
        withoutMoved = @.epics.filter (it) => it.get('id') != epic.get('id')
        beforeDestination = withoutMoved.slice(0, newIndex)
        previous = beforeDestination.last()

        newOrder = if !previous then 0 else previous.get('epics_order') + 1

        previousWithTheSameOrder = beforeDestination.filter (it) =>
            it.get('epics_order') == previous.get('epics_order')
        setOrders = _.fromPairs previousWithTheSameOrder.map((it) =>
            [it.get('id'), it.get('epics_order')]
        ).toJS()

        data = {
            epics_order: newOrder,
            version: epic.get('version')
        }

        return @resources.epics.reorder(epic.get('id'), data, setOrders)
            .then () =>
                @.fetchEpics()

    reorderRelatedUserstory: (epic, epicUserstories, userstory, newIndex) ->
        withoutMoved = epicUserstories.filter (it) => it.get('id') != userstory.get('id')
        beforeDestination = withoutMoved.slice(0, newIndex)

        previous = beforeDestination.last()
        newOrder = if !previous then 0 else previous.get('epic_order') + 1

        previousWithTheSameOrder = beforeDestination.filter (it) =>
            it.get('epic_order') == previous.get('epic_order')

        setOrders = Immutable.OrderedMap previousWithTheSameOrder.map (it) =>
            [it.get('id'), it.get('epic_order')]

        data = {
            order: newOrder
        }
        epicId = epic.get('id')
        userstoryId = userstory.get('id')
        return @resources.epics.reorderRelatedUserstory(epicId, userstoryId, data, setOrders)
            .then () =>
                return @.listRelatedUserStories(epic)

    updateEpicStatus: (epic, statusId) ->
        data = {
            status: statusId,
            version: epic.get('version')
        }

        return @resources.epics.patch(epic.get('id'), data)
            .then () =>
                @.fetchEpics()

    updateEpicAssignedTo: (epic, userId) ->
        data = {
            assigned_to: userId,
            version: epic.get('version')
        }

        return @resources.epics.patch(epic.get('id'), data)
            .then () =>
                @.fetchEpics()

angular.module('taigaEpics').service('tgEpicsService', EpicsService)
