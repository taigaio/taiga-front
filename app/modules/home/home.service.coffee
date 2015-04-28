class HomeService extends taiga.Service
    @.$inject = ["$q", "$tgResources", "$rootScope", "$projectUrl"]

    constructor: (@q, @rs, @rootScope, @projectUrl) ->
        @.workInProgress = Immutable.Map()
        @.inProgress = false

    fetchWorkInProgress: (userId) ->
        if not @.inProgress
            @.inProgress = true
            params = {
                status__is_closed: false
                assigned_to: userId
            }
            assignedUserStoriesPromise = @rs.userstories.listInAllProjects(params).then (userstories) =>
                @.assignedToUserStories = userstories

            assignedTasksPromise = @rs.tasks.listInAllProjects(params).then (tasks) =>
                @.assignedToTasks = tasks

            assignedIssuesPromise = @rs.issues.listInAllProjects(params).then (issues) =>
                @.assignedToIssues = issues

            params = {
                status__is_closed: false
                watchers: userId
            }
            watchingUserStoriesPromise = @rs.userstories.listInAllProjects(params).then (userstories) =>
                @.watchingUserStories = userstories

            watchingTasksPromise = @rs.tasks.listInAllProjects(params).then (tasks) =>
                @.watchingTasks = tasks

            watchingIssuesPromise = @rs.issues.listInAllProjects(params).then (issues) =>
                @.watchingIssues = issues

            workPromise = @q.all([assignedUserStoriesPromise, assignedTasksPromise,
                assignedIssuesPromise, watchingUserStoriesPromise,
                watchingUserStoriesPromise, watchingIssuesPromise])

            workPromise.then =>
                @.workInProgress = Immutable.fromJS({
                    assignedTo: {
                        userStories: @.assignedToUserStories
                        tasks: @.assignedToTasks
                        issues: @.assignedToIssues
                    }
                    watching: {
                        userStories: @.watchingUserStories
                        tasks: @.watchingTasks
                        issues: @.watchingIssues
                    }
                })

                @.inProgress = false

        return workPromise

angular.module("taigaHome").service("tgHomeService", HomeService)
