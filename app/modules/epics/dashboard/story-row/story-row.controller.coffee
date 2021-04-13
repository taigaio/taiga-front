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
