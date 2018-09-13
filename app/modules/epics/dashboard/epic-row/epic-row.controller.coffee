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
# File: epics/dashboard/epic-row/epic-row.controller.coffee
###

class EpicRowController
    @.$inject = [
        "$tgConfirm",
        "tgProjectService",
        "tgEpicsService"
    ]

    constructor: (@confirm, @projectService, @epicsService) ->
        @.displayUserStories = false
        @.displayAssignedTo = false
        @.displayStatusList = false
        @.loadingStatus = false

        # NOTE: We use project as no inmutable object to make
        #       the code compatible with the old code
        @.project = @projectService.project.toJS()

        @._calculateProgressBar()

    _calculateProgressBar: () ->
        if @.epic.getIn(['status_extra_info', 'is_closed']) == true
            @.percentage = "100%"
        else
            progress = @.epic.getIn(['user_stories_counts', 'progress'])
            total = @.epic.getIn(['user_stories_counts', 'total'])
            if total == 0
                @.percentage = "0%"
            else
                @.percentage = "#{progress * 100 / total}%"

    canEditEpics: () ->
        return @projectService.hasPermission("modify_epic")

    toggleUserStoryList: () ->
        if !@.displayUserStories
            @epicsService.listRelatedUserStories(@.epic)
                .then (userStories) =>
                    @.epicStories = userStories
                    @.displayUserStories = true
                .catch =>
                    @confirm.notify('error')
        else
            @.displayUserStories = false

    updateStatus: (statusId) ->
        @.displayStatusList = false
        @.loadingStatus = true
        return @epicsService.updateEpicStatus(@.epic, statusId)
            .catch () =>
                @confirm.notify('error')
            .finally () =>
                @.loadingStatus = false

    updateAssignedTo: (member) ->
        @.assignLoader = true
        return @epicsService.updateEpicAssignedTo(@.epic, member?.id or null)
            .catch () =>
                @confirm.notify('error')
            .then () =>
                @.assignLoader = false

angular.module("taigaEpics").controller("EpicRowCtrl", EpicRowController)
