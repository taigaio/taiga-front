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
        @.displayAssignedTo = false
        @.loadingStatus = false

    _calculateProgressBar: () ->
        if @.epic.getIn(['status_extra_info', 'is_closed']) == true
            @.percentage = "100%"
        else
            @.opened = @.epic.getIn(['user_stories_counts', 'opened'])
            @.closed = @.epic.getIn(['user_stories_counts', 'closed'])
            @.total = @.opened + @.closed
            if @.total == 0
                @.percentage = "0%"
            else
                @.percentage = "#{@.closed * 100 / @.total}%"

    updateEpicStatus: (status) ->
        @.loadingStatus = true
        @.displayStatusList = false
        patch = {
            'status': status,
            'version': @.epic.get('version')
        }

        onSuccess = =>
            @.loadingStatus = false
            @.onUpdateEpic()

        onError = (data) =>
            @confirm.notify('error')

        return @rs.epics.patch(@.epic.get('id'), patch).then(onSuccess, onError)

    requestUserStories: (epic) ->
        if !@.displayUserStories

            onSuccess = (data) =>
                @.epicStories = data
                @.displayUserStories = true

            onError = (data) =>
                @confirm.notify('error')

            return @rs.userstories.listInEpic(@.epic.get('id')).then(onSuccess, onError)
        else
            @.displayUserStories = false

    onRemoveAssigned: () ->
        id = @.epic.get('id')
        version = @.epic.get('version')
        patch = {
            'assigned_to': null,
            'version': version
        }

        onSuccess = =>
            @.onUpdateEpic()

        onError = (data) =>
            @confirm.notify('error')

        return @rs.epics.patch(id, patch).then(onSuccess, onError)

    onAssignTo: (member) ->
        id = @.epic.get('id')
        version = @.epic.get('version')
        patch = {
            'assigned_to': member.id,
            'version': version
        }

        onSuccess = =>
            @.onUpdateEpic()
            @confirm.notify('success')

        onError = (data) =>
            @confirm.notify('error')

        return @rs.epics.patch(id, patch).then(onSuccess, onError)

module.controller("EpicRowCtrl", EpicRowController)
