class HomeService extends taiga.Service
    @.$inject = ["$q", "$tgNavUrls", "tgResources", "$rootScope", "$projectUrl", "$tgAuth"]

    constructor: (@q, @navurls, @rs, @rootScope, @projectUrl, @auth) ->
        @._workInProgress = Immutable.Map()
        @._projectPromise = null
        @._inProgress = false

        taiga.defineImmutableProperty @, "workInProgress", () => return @._workInProgress

        @.fetchWorkInProgress()

    attachProjectInfoToWorkInProgress: (projectsById) ->
        _attachProjectInfoToDuty = (duty, objType) =>
            project = projectsById.get(String(duty.get('project')))
            ctx = {
                project: project.get('slug')
                ref: duty.get('ref')
            }

            url = @navurls.resolve("project-#{objType}-detail", ctx)

            duty = duty.set('url', url)
            duty = duty.set('projectName', project.get('name'))
            duty = duty.set("_name", objType)

            return duty

        assignedTo = Immutable.Map()

        if @.assignedToUserStories
            _duties = @.assignedToUserStories.map (duty) ->
                return _attachProjectInfoToDuty(duty, "userstories")

            assignedTo = assignedTo.set("userStories", _duties)

        if @.assignedToTasks
            _duties = @.assignedToTasks.map (duty) ->
                return _attachProjectInfoToDuty(duty, "tasks")

            assignedTo = assignedTo.set("tasks", _duties)

        if @.assignedToIssues
            _duties = @.assignedToIssues.map (duty) ->
                return _attachProjectInfoToDuty(duty, "issues")

            assignedTo = assignedTo.set("issues", _duties)

        watching = Immutable.Map()

        if @.watchingUserStories
            _duties = @.watchingUserStories.map (duty) ->
                return _attachProjectInfoToDuty(duty, "userstories")

            watching = watching.set("userStories", _duties)

        if @.watchingTasks
            _duties = @.watchingTasks.map (duty) ->
                return _attachProjectInfoToDuty(duty, "tasks")

            watching = watching.set("tasks", _duties)

        if @.watchingIssues
            _duties = @.watchingIssues.map (duty) ->
                return _attachProjectInfoToDuty(duty, "issues")

            watching = watching.set("issues", _duties)

        @._workInProgress = Immutable.Map({
            assignedTo: assignedTo,
            watching: watching
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
