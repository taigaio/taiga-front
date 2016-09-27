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
# File: epics-table.controller.coffee
###

taiga = @.taiga


class EpicsTableController
    @.$inject = [
        "$tgConfirm",
        "tgEpicsService",
        "$timeout"
    ]

    constructor: (@confirm, @epicsService, @timeout) ->
        @.displayOptions = false
        @.displayVotes = true
        @.column = {
            votes: true,
            name: true,
            project: true,
            sprint: true,
            assigned: true,
            status: true,
            progress: true
        }

        taiga.defineImmutableProperty @, 'epics', () => return @epicsService.epics

    toggleEpicTableOptions: () ->
        @.displayOptions = !@.displayOptions

    reorderEpic: (epic, newIndex) ->
        @epicsService.reorderEpic(epic, newIndex)
            .then null, () => # on error
                @confirm.notify("error")

    hoverEpicTableOption: () ->
        if @.timer
            @timeout.cancel(@.timer)

    hideEpicTableOption: () ->
        return @.timer = @timeout (=> @.displayOptions = false), 400

angular.module("taigaEpics").controller("EpicsTableCtrl", EpicsTableController)
