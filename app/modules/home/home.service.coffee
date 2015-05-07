class HomeService extends taiga.Service
    @.$inject = ["$q", "$tgNavUrls", "$tgResources", "$rootScope", "$projectUrl", "$tgAuth"]

    constructor: (@q, @navurls, @rs, @rootScope, @projectUrl, @auth) ->
        @._workInProgress = Immutable.Map()
        @._projectPromise = null
        @._inProgress = false

        taiga.defineImmutableProperty @, "workInProgress", () => return @._workInProgress

        @.fetchWorkInProgress()

    attachProjectInfoToWorkInProgress: (projectsById) ->
        _attachProjectInfoToDuty = (duty) =>
            project = projectsById.get(String(duty.project))
            ctx = {
                project: project.slug
                ref: duty.ref
            }
            Object.defineProperty(duty, "url", {get: () => @navurls.resolve("project-#{duty._name}-detail", ctx)})
            Object.defineProperty(duty, "projectName", {get: () => project.name})

        @._workInProgress = Immutable.fromJS({
            assignedTo: {
                userStories: _.map(_.clone(@.assignedToUserStories), _attachProjectInfoToDuty)
                tasks: _.map(_.clone(@.assignedToTasks), _attachProjectInfoToDuty)
                issues: _.map(_.clone(@.assignedToIssues), _attachProjectInfoToDuty)
            }
            watching: {
                userStories: _.map(_.clone(@.watchingUserStories), _attachProjectInfoToDuty)
                tasks: _.map(_.clone(@.watchingTasks), _attachProjectInfoToDuty)
                issues: _.map(_.clone(@.watchingIssues), _attachProjectInfoToDuty)
            }
        })

    getWorkInProgress: () ->
        return @._projectPromise

    fetchWorkInProgress: () ->
        userId = @auth.getUser().id

        if not @._inProgress
            @._inProgress = true
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

            @._projectPromise = @q.all([assignedUserStoriesPromise, assignedTasksPromise,
                assignedIssuesPromise, watchingUserStoriesPromise,
                watchingUserStoriesPromise, watchingIssuesPromise])

            @._projectPromise.then =>
                @._workInProgress = Immutable.fromJS({
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

                @._inProgress = false

        return @._projectPromise

angular.module("taigaHome").service("tgHomeService", HomeService)
