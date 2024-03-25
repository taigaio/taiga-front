###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
            totalTasks = @.story.get('tasks').size
            totalTasksCompleted = @.story.get('tasks').filter((it) -> it.get("is_closed")).size
            if totalTasks == 0
                @.percentage = "0%"
            else
                @.percentage = "#{totalTasksCompleted * 100 / totalTasks}%"

module.controller("StoryRowCtrl", StoryRowController)
