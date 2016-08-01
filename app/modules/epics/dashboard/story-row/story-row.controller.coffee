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

class StoryRowController
    @.$inject = []

    constructor: () ->
        @._calculateProgressBar()

    _calculateProgressBar: () ->
        if @.story.get('is_closed') == true
            @.percentage = "100%"
        else
            tasks = @.story.get('tasks').toJS()
            totalTasks = @.story.get('tasks').size
            areTasksCompleted = _.map(tasks, 'is_closed')
            totalTasksCompleted = _.pull(areTasksCompleted, false).length
            @.percentage = "#{totalTasksCompleted * 100 / totalTasks}%"

    onSelectAssignedTo: () ->
        console.log 'ng-click="vm.onSelectAssignedTo()"'

module.controller("StoryRowCtrl", StoryRowController)
