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
# File: epics/dashboard/epics-table/epics-table.controller.coffee
###

taiga = @.taiga
generateHash = @.taiga.generateHash

class EpicsTableController
    @.$inject = [
        "$tgConfirm",
        "tgEpicsService",
        "$timeout",
        "$tgStorage",
        "tgProjectService"
    ]

    constructor: (@confirm, @epicsService, @timeout, @storage, @projectService) ->
        @.hash = generateHash([@projectService.project.get('id'), 'epics'])
        @.displayOptions = false
        @.displayVotes = true
        @.column = @storage.get(@.hash, {
            votes: true,
            name: true,
            project: true,
            sprint: true,
            assigned: true,
            status: true,
            progress: true
        })

        taiga.defineImmutableProperty @, 'epics', () => return @epicsService.epics
        taiga.defineImmutableProperty @, 'disabledEpicsPagination', () => return @epicsService._disablePagination
        taiga.defineImmutableProperty @, 'loadingEpics', () => return @epicsService._loadingEpics

    toggleEpicTableOptions: () ->
        @.displayOptions = !@.displayOptions

    reorderEpic: (epic, newIndex) ->
        if epic.get('epics_order') == newIndex
            return null

        @epicsService.reorderEpic(epic, newIndex)
            .then null, () => # on error
                @confirm.notify("error")

    nextPage: () ->
        @epicsService.nextPage()

    hoverEpicTableOption: () ->
        if @.timer
            @timeout.cancel(@.timer)

    hideEpicTableOption: () ->
        return @.timer = @timeout (=> @.displayOptions = false), 400

    updateViewOptions: () ->
        @storage.set(@.hash, @.column)

angular.module("taigaEpics").controller("EpicsTableCtrl", EpicsTableController)
