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

module = angular.module("taigaEpics")

class EpicRowController
    @.$inject = [
        "tgResources",
        "$tgConfirm"
    ]

    constructor: (@rs, @confirm) ->
        @.displayUserStories = false
        @._calculateProgressBar()
        @.displayAssignedTo = false

    _calculateProgressBar: () ->
        if @.epic.getIn(['status_extra_info', 'is_closed']) == true
            @.percentage = "100%"
        else
            opened = @.epic.getIn(['user_stories_counts', 'opened'])
            closed = @.epic.getIn(['user_stories_counts', 'closed'])
            total = opened + closed
            if total == 0
                @.percentage = "0%"
            else
                @.percentage = "#{closed * 100 / total}%"

    updateEpicStatus: (status) ->
        id = @.epic.get('id')
        version = @.epic.get('version')
        patch = {
            'status': status,
            'version': version
        }

        onSuccess = =>
            @.onUpdateEpicStatus()

        onError = (data) =>
            @confirm.notify('error')

        return @rs.epics.patch(id, patch).then(onSuccess, onError)

    requestUserStories: (epic) ->
        if @.displayUserStories == false
            id = @.epic.get('id')

            onSuccess = (data) =>
                @.epicStories = data
                @.displayUserStories = true

            onError = (data) =>
                @confirm.notify('error')

            return @rs.userstories.listInEpic(id).then(onSuccess, onError)
        else
            @.displayUserStories = false

    onSelectAssignedTo: () ->
        console.log 'Assigned to'

module.controller("EpicRowCtrl", EpicRowController)
