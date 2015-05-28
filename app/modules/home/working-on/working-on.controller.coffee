class WorkingOnController
    @.$inject = [
        "tgHomeService"
    ]

    constructor: (@homeService) ->
        @.assignedTo = Immutable.Map()
        @.watching = Immutable.Map()

    _setAssignedTo: (workInProgress) ->
        userStories = workInProgress.get("assignedTo").get("userStories")
        tasks = workInProgress.get("assignedTo").get("tasks")
        issues = workInProgress.get("assignedTo").get("issues")

        @.assignedTo = userStories.concat(tasks).concat(issues)
        if @.assignedTo.size > 0
            @.assignedTo = @.assignedTo.sortBy((elem) -> elem.get("modified_date")).reverse()

    _setWatching: (workInProgress) ->
        userStories = workInProgress.get("watching").get("userStories")
        tasks = workInProgress.get("watching").get("tasks")
        issues = workInProgress.get("watching").get("issues")

        @.watching = userStories.concat(tasks).concat(issues)
        if @.watching.size > 0
            @.watching = @.watching.sortBy((elem) -> elem.get("modified_date")).reverse()

    getWorkInProgress: (userId) ->
        return @homeService.getWorkInProgress(userId).then (workInProgress) =>
            @._setAssignedTo(workInProgress)
            @._setWatching(workInProgress)

angular.module("taigaHome").controller("WorkingOn", WorkingOnController)
