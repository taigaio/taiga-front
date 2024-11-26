###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
toggleText = @.taiga.toggleText
mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
scopeDefer = @.taiga.scopeDefer
timeout = @.taiga.timeout
bindMethods = @.taiga.bindMethods
debounceLeading = @.taiga.debounceLeading

module = angular.module("taigaTaskboard")


#############################################################################
## Taskboard Controller
#############################################################################

class TaskboardController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "tgResources"
        "$routeParams",
        "$q",
        "tgAppMetaService",
        "$tgLocation",
        "$tgNavUrls"
        "$tgEvents"
        "$tgAnalytics",
        "$translate",
        "tgErrorHandlingService",
        "tgTaskboardTasks",
        "tgTaskboardIssues",
        "$tgStorage",
        "tgFilterRemoteStorageService",
        "tgLightboxFactory",
        "$timeout",
        "tgProjectService"
    ]

    excludePrefix: "exclude_"
    filterCategories: [
        "status",
        "assigned_to",
        "owner",
        "role",
        "tags"
    ]

    validQueryParams: [
        'exclude_status',
        'status',
        'exclude_assigned_to',
        'assigned_to',
        'exclude_role',
        'role',
        'exclude_owner',
        'owner',
        'order_by',
        'tags'
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @rs2, @params, @q, @appMetaService, @location, @navUrls,
                  @events, @analytics, @translate, @errorHandlingService, @taskboardTasksService,
                  @taskboardIssuesService, @storage, @filterRemoteStorageService, @lightboxFactory, @timeout, @projectService) ->
        bindMethods(@)
        @taskboardTasksService.reset()
        @scope.userstories = []
        @.openFilter = false
        @.filterQ = ''
        @.backToBacklogUrl = @navUrls.resolve('project-backlog', {
            project: @projectService.project.get('slug'),
            ref: @params.ref
        })

        return if @.applyStoredFilters(@params.pslug, "tasks-filters", @.validQueryParams)

        @scope.sectionName = @translate.instant("TASKBOARD.SECTION_NAME")
        @.initializeEventHandlers()

        taiga.defineImmutableProperty @.scope, "usTasks", () =>
            return @taskboardTasksService.usTasks

        taiga.defineImmutableProperty @.scope, "taskMap", () =>
            return @taskboardTasksService.taskMap

        taiga.defineImmutableProperty @.scope, "milestoneIssues", () =>
            return @taskboardIssuesService.milestoneIssues

        taiga.defineImmutableProperty @.scope, "tasksByUs", () =>
            return @taskboardTasksService.tasksByUs

        @scope.issues = []
        @scope.showTags = true

        @scope.$watch 'milestoneIssues', () =>
            if @scope.milestoneIssues
                @scope.issues = @scope.milestoneIssues.toJS().map (milestoneIssue) =>
                    return @taskboardIssuesService.issuesRaw.find (rawIssue) => milestoneIssue.model.id == rawIssue.id
            else
                @scope.issues = []

    getQueryParams: () ->
        return _.pick(_.clone(@location.search()), @.validQueryParams)

    firstLoad: () ->
        promise = @.loadInitialData()

        # On Success
        promise.then => @._setMeta()
        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    setZoom: (zoomLevel, zoom) ->
        if @.zoomLevel == Number(zoomLevel)
            return null

        @.isFirstLoad = !@.zoomLevel

        previousZoomLevel = @.zoomLevel

        @.zoomLevel = zoomLevel
        @.zoom = zoom

        if @.isFirstLoad
            @.firstLoad().then () =>
                @.isFirstLoad = false
                @taskboardTasksService.resetFolds()

        else if @.zoomLevel > 1 && previousZoomLevel <= 1
            @.zoomLoading = true
            @q.all([@.loadTasks(), @.loadIssues()]).then () =>
                @.zoomLoading = false
                @taskboardTasksService.resetFolds()

    changeQ: (q) ->
        @.filterQ = q
        @.loadTasks()
        @.generateFilters()

    removeFilter: (filter) ->
        @.unselectFilter(filter.dataType, filter.id, false, filter.mode)
        @.loadTasks()
        @.generateFilters()

    addFilter: (newFilter) ->
        @.selectFilter(newFilter.category.dataType, newFilter.filter.id, false, newFilter.mode)
        @.loadTasks()
        @.generateFilters()

    selectCustomFilter: (customFilter) ->
        @.replaceAllFilters(customFilter.filter)
        @.loadTasks()
        @.generateFilters()

    removeCustomFilter: (customFilter) ->
        @filterRemoteStorageService.getFilters(@scope.projectId, 'tasks-custom-filters').then (userFilters) =>
            delete userFilters[customFilter.id]

            @filterRemoteStorageService.storeFilters(@scope.projectId, userFilters, 'tasks-custom-filters').then(@.generateFilters)

    isFilterDataTypeSelected: (filterDataType) ->
        for filter in @.selectedFilters
            if (filter['dataType'] == filterDataType)
                return true
        return false

    saveCustomFilter: (name) ->
        filters = {}
        urlfilters = @.getQueryParams()
        for key in @.filterCategories
            excludeKey = @.excludePrefix.concat(key)
            filters[key] = urlfilters[key]
            filters[excludeKey] = urlfilters[excludeKey]

        @filterRemoteStorageService.getFilters(@scope.projectId, 'tasks-custom-filters').then (userFilters) =>
            userFilters[name] = filters

            @filterRemoteStorageService.storeFilters(@scope.projectId, userFilters, 'tasks-custom-filters').then(@.generateFilters)

    generateFilters: ->
        urlfilters = @.getQueryParams()
        @.storeFilters(@params.pslug, urlfilters, "tasks-filters")

        loadFilters = {}
        loadFilters.project = @scope.projectId
        loadFilters.milestone = @scope.sprintId

        for key in @.filterCategories
            excludeKey = @.excludePrefix.concat(key)
            loadFilters[key] = urlfilters[key]
            loadFilters[excludeKey] = urlfilters[excludeKey]

        return @q.all([
            @rs.tasks.filtersData(loadFilters),
            @filterRemoteStorageService.getFilters(@scope.projectId, 'tasks-custom-filters')
        ]).then (result) =>
            data = result[0]
            customFiltersRaw = result[1]
            dataCollection = {}

            dataCollection.status = _.map data.statuses, (it) ->
                it.id = it.id.toString()

                return it
            dataCollection.tags = _.map data.tags, (it) ->
                it.id = it.name

                return it

            tagsWithAtLeastOneElement = _.filter dataCollection.tags, (tag) ->
                return tag.count > 0

            dataCollection.assigned_to = _.map data.assigned_to, (it) ->
                if it.id
                    it.id = it.id.toString()
                else
                    it.id = "null"

                it.name = it.full_name || "Unassigned"

                return it
            dataCollection.role = _.map data.roles, (it) ->
                if it.id
                    it.id = it.id.toString()
                else
                    it.id = "null"

                it.name = it.name || "Unassigned"

                return it
            dataCollection.owner = _.map data.owners, (it) ->
                it.id = it.id.toString()
                it.name = it.full_name

                return it

            @.selectedFilters = []

            for key in @.filterCategories
                excludeKey = @.excludePrefix.concat(key)
                if loadFilters[key]
                    selected = @.formatSelectedFilters(key, dataCollection[key], loadFilters[key])
                    @.selectedFilters = @.selectedFilters.concat(selected)
                if loadFilters[excludeKey]
                    selected = @.formatSelectedFilters(key, dataCollection[key], loadFilters[excludeKey], "exclude")
                    @.selectedFilters = @.selectedFilters.concat(selected)

            @.filters = [
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.STATUS"),
                    dataType: "status",
                    content: dataCollection.status
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.TAGS"),
                    dataType: "tags",
                    content: dataCollection.tags,
                    hideEmpty: true,
                    totalTaggedElements: tagsWithAtLeastOneElement.length
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.ASSIGNED_TO"),
                    dataType: "assigned_to",
                    content: dataCollection.assigned_to
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.ROLE"),
                    dataType: "role",
                    content: dataCollection.role
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.CREATED_BY"),
                    dataType: "owner",
                    content: dataCollection.owner
                }
            ]

            @.customFilters = []
            _.forOwn customFiltersRaw, (value, key) =>
                @.customFilters.push({id: key, name: key, filter: value})

    _setMeta: ->
        prettyDate = @translate.instant("BACKLOG.SPRINTS.DATE")

        title = @translate.instant("TASKBOARD.PAGE_TITLE", {
            projectName: @scope.project.name
            sprintName: @scope.sprint.name
        })
        description =  @translate.instant("TASKBOARD.PAGE_DESCRIPTION", {
            projectName: @scope.project.name
            sprintName: @scope.sprint.name
            startDate: moment(@scope.sprint.estimated_start).format(prettyDate)
            endDate: moment(@scope.sprint.estimated_finish).format(prettyDate)
            completedPercentage: @scope.stats.completedPercentage or "0"
            completedPoints: @scope.stats.completedPointsSum or "--"
            totalPoints: @scope.stats.totalPointsSum or "--"
            openTasks: @scope.stats.openTasks or "--"
            totalTasks: @scope.stats.total_tasks or "--"
        })

        @appMetaService.setAll(title, description)

    initializeEventHandlers: ->
        @scope.$on "taskform:bulk:success", (event, tasks) =>
            @.refreshTagsColors().then () =>
                @taskboardTasksService.add(tasks)

            @analytics.trackEvent("task", "create", "bulk create task on taskboard", 1)

        @scope.$on "taskform:new:success", (event, task) =>
            @.refreshTagsColors().then () =>
                @taskboardTasksService.add(task)

            @analytics.trackEvent("task", "create", "create task on taskboard", 1)

        @scope.$on "taskform:edit:success", (event, task) =>
            @.refreshTagsColors().then () =>
                @taskboardTasksService.replaceModel(task)

        @scope.$on "issueform:new:success", (event, issue) =>
            @.refreshTagsColors().then () =>
                @taskboardIssuesService.add(issue)

            @analytics.trackEvent("issue", "create", "create issue on taskboard", 1)

        @scope.$on "issueform:add:success", (event, issue) =>
            @.refreshTagsColors().then () =>
                @taskboardIssuesService.add(issue)

        @scope.$on "issueform:edit:success", (event, issue) =>
            @.refreshTagsColors().then () =>
                @taskboardIssuesService.replaceModel(issue)

        @scope.$on "taskboard:task:deleted", (event, task) =>
            @.loadTasks()

        @scope.$on "taskboard:issue:deleted", (event, issue) =>
            @.loadIssues()

        @scope.$on("taskboard:task:move", @.taskMove)
        @scope.$on("assigned-to:added", @.onAssignedToChanged)

        @scope.$on "taskboard:items:move", (event, itemsMoved) =>
            if itemsMoved.uss
                @.firstLoad()
            else
                @.loadTasks() if itemsMoved.tasks
                @.loadIssues() if itemsMoved.issues

    onAssignedToChanged: (ctx, userid, model) ->
        if model.getName() == 'tasks'
            model.assigned_to = userid
            @taskboardTasksService.replaceModel(model)

            @repo.save(model).then =>
                @.generateFilters()
                if @.isFilterDataTypeSelected('assigned_to') || @.isFilterDataTypeSelected('role')
                    @.loadTasks()
        if model.getName() == 'issues'
            model.assigned_to = userid
            @taskboardIssuesService.replaceModel(model)

            @repo.save(model).then =>
                @.generateFilters()
                if @.isFilterDataTypeSelected('assigned_to') || @.isFilterDataTypeSelected('role')
                    @.loadIssues()

    initializeSubscription: ->
        routingKey = "changes.project.#{@scope.projectId}.tasks"
        @events.subscribe @scope, routingKey, debounceLeading(500, (message) =>
            @.loadTaskboard())

        routingKey = "changes.project.#{@scope.projectId}.issues"
        @events.subscribe @scope, routingKey, debounceLeading(500, (message) =>
            @.loadIssues())

        routingKey1 = "changes.project.#{@scope.projectId}.userstories"
        @events.subscribe @scope, routingKey1, (message) =>
            @.refreshTagsColors()
            @.loadSprintStats()
            @.loadSprint()

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            if not project.is_backlog_activated
                @errorHandlingService.permissionDenied()

            @scope.project = project
            # Not used at this momment
            @scope.pointsList = _.sortBy(project.points, "order")
            @scope.pointsById = groupBy(project.points, (e) -> e.id)
            @scope.roleById = groupBy(project.roles, (e) -> e.id)
            @scope.taskStatusList = _.sortBy(project.task_statuses, "order")
            @scope.usStatusList = _.sortBy(project.us_statuses, "order")
            @scope.usStatusById = groupBy(project.us_statuses, (e) -> e.id)
            @scope.issueStatusById = groupBy(project.issue_statuses, (e) -> e.id)

            @scope.$emit('project:loaded', project)

            @.fillUsersAndRoles(project.members, project.roles)

            return project

    loadSprintStats: ->
        return @rs.sprints.stats(@scope.projectId, @scope.sprintId).then (stats) =>
            totalPointsSum =_.reduce(_.values(stats.total_points), ((res, n) -> res + n), 0)
            completedPointsSum = _.reduce(_.values(stats.completed_points), ((res, n) -> res + n), 0)
            remainingPointsSum = totalPointsSum - completedPointsSum
            remainingTasks = stats.total_tasks - stats.completed_tasks
            @scope.stats = stats
            @scope.stats.totalPointsSum = totalPointsSum
            @scope.stats.completedPointsSum = completedPointsSum
            @scope.stats.remainingPointsSum = remainingPointsSum
            @scope.stats.remainingTasks = remainingTasks
            if stats.totalPointsSum
                @scope.stats.completedPercentage = Math.round(100*stats.completedPointsSum/stats.totalPointsSum)
            else
                @scope.stats.completedPercentage = 0

            @scope.stats.openTasks = stats.total_tasks - stats.completed_tasks
            return stats

    refreshTagsColors: ->
        return @rs.projects.tagsColors(@scope.projectId).then (tags_colors) =>
            @scope.project.tags_colors = tags_colors._attrs

    loadSprint: ->
        return @rs.sprints.get(@scope.projectId, @scope.sprintId).then (sprint) =>
            @scope.sprint = sprint
            @scope.userstories = _.sortBy(sprint.user_stories, "sprint_order")

            @taskboardTasksService.setUserstories(@scope.userstories)

            @rootscope.$broadcast("taskboard:userstories:loaded", @scope.userstories)
            return sprint

    loadIssues: ->
        params = {}

        if @.zoomLevel > 1
            params.include_attachments = 1

        locationParams = @.getQueryParams()
        params = _.merge params, locationParams

        return @rs.issues.listInProject(@scope.projectId, @scope.sprintId, params).then (issues) =>
            @taskboardIssuesService.init(@scope.project, @scope.usersById, @scope.issueStatusById)
            @taskboardIssuesService.set(issues)
            @.initIssues = true

    loadTasks: ->
        params = {}

        if @.zoomLevel > 1
            params.include_attachments = 1

        locationParams = @.getQueryParams()
        params = _.merge params, locationParams
        params.q = @.filterQ

        return @rs.tasks.list(@scope.projectId, @scope.sprintId, null, params).then (tasks) =>
            @.notFoundTasks = false

            if !tasks.length && ((@.filterQ && @.filterQ.length) || Object.keys(locationParams).length)
                @.notFoundTasks = true

            @taskboardTasksService.init(@scope.project, @scope.usersById)
            @taskboardTasksService.set(tasks)

    loadTaskboard: ->
        return @q.all([
            @.refreshTagsColors(),
            @.loadSprintStats(),
            @.loadSprint().then(=>
                @.loadTasks()
                @.loadIssues()
            )
        ])

    loadInitialData: ->
        @.initialLoad = false
        @.initIssues = false

        params = {
            pslug: @params.pslug
            sslug: @params.sslug
        }

        promise = @repo.resolve(params).then (data) =>
            @scope.projectId = data.project
            @scope.sprintId = data.milestone
            @.initializeSubscription()
            return data

        return promise.then(=> @.loadProject()).then =>
            @.generateFilters()

            if @rs.issues.getSprintShowTags(@scope.projectId) == false
                @scope.showTags = false

            return @.loadTaskboard().then () =>
                @timeout () =>
                    @.initialLoad = true
                , 0, false
                @.setRolePoints()

    toggleTags: (tags) ->
        @rs.issues.storeSprintShowTags(@scope.projectId, tags)

    showPlaceHolder: (statusId, usId) ->
        if !@taskboardTasksService.tasksRaw.length
            if @scope.taskStatusList[0].id == statusId &&
              (!@scope.userstories.length || @scope.userstories[0].id == usId)
                return true

        return false

    editTask: (id) ->
        task = @.taskboardTasksService.getTask(id)

        task = task.set('loading-edit', true)
        @taskboardTasksService.replace(task)

        @rs.tasks.getByRef(task.getIn(['model', 'project']), task.getIn(['model', 'ref']))
        .then (editingTask) =>
            @rs2.attachments.list("task", task.get('id'), task.getIn(['model', 'project']))
            .then (attachments) =>
                @rootscope.$broadcast("genericform:edit", {
                    'objType': 'task',
                    'obj': editingTask,
                    'project': @scope.project,
                    'sprintId': @scope.sprintId,
                    'attachments': attachments.toJS()
                })

                task = task.set('loading-edit', false)
                @taskboardTasksService.replace(task)

    editIssue: (id) ->
        issue = @.taskboardIssuesService.getIssue(id)
        issue = issue.set('loading-edit', true)

        @rs.issues.getByRef(issue.getIn(['model', 'project']), issue.getIn(['model', 'ref']))
        .then (editingIssue) =>
            @rs2.attachments.list("issue", issue.get('id'), issue.getIn(['model', 'project']))
            .then (attachments) =>
                @rootscope.$broadcast("genericform:edit", {
                    'objType': 'issue',
                    'obj': editingIssue,
                    'project': @scope.project,
                    'sprintId': @scope.sprintId,
                    'attachments': attachments.toJS()
                })
                issue = issue.set('loading-edit', false)

    deleteTask: (id) ->
        task = @.taskboardTasksService.getTask(id)
        task = task.set('loading-delete', true)

        @rs.tasks.getByRef(task.getIn(['model', 'project']), task.getIn(['model', 'ref']))
        .then (deletingTask) =>
            task = task.set('loading-delete', false)
            title = @translate.instant("TASK.TITLE_DELETE_ACTION")
            message = deletingTask.subject
            @confirm.askOnDelete(title, message).then (askResponse) =>
                promise = @repo.remove(deletingTask)
                promise.then =>
                    @scope.$broadcast("taskboard:task:deleted")
                    askResponse.finish()
                promise.then null, ->
                    askResponse.finish(false)
                    @confirm.notify("error")

    deleteIssue: (id) ->
        issue = @.taskboardIssuesService.getIssue(id)
        issue = issue.set('loading-delete', true)

        @rs.issues.getByRef(issue.getIn(['model', 'project']), issue.getIn(['model', 'ref']))
        .then (deletingIssue) =>
            issue = issue.set('loading-delete', false)
            title = @translate.instant("ISSUES.ACTION_DELETE")
            message = deletingIssue.subject
            @confirm.askOnDelete(title, message).then (askResponse) =>
                promise = @repo.remove(deletingIssue)
                promise.then =>
                    @scope.$broadcast("taskboard:issue:deleted")
                    askResponse.finish()
                promise.then null, ->
                    askResponse.finish(false)
                    @confirm.notify("error")

    removeIssueFromSprint: (id) ->
        issue = @.taskboardIssuesService.getIssue(id)
        issue = issue.set('loading-delete', true)

        @rs.issues.getByRef(issue.getIn(['model', 'project']), issue.getIn(['model', 'ref']))
        .then (removingIssue) =>
            issue = issue.set('loading-delete', false)
            title = @translate.instant("ISSUES.CONFIRM_DETACH_FROM_SPRINT.TITLE")
            message = @translate.instant("ISSUES.CONFIRM_DETACH_FROM_SPRINT.MESSAGE")
            message = @translate.instant(
                "ISSUES.CONFIRM_DETACH_FROM_SPRINT.MESSAGE",
                {sprintName: @scope.sprint.name}
            )

            @confirm.ask(title, null, message).then (askResponse) =>
                removingIssue.milestone = null
                promise = @repo.save(removingIssue)
                promise.then =>
                    @.taskboardIssuesService.remove(removingIssue)
                    askResponse.finish()
                promise.then null, ->
                    askResponse.finish(false)
                    @confirm.notify("error")

    taskMove: (ctx, task, oldStatusId, usId, statusId, order) ->
        @scope.movingTask = true
        task = @taskboardTasksService.getTaskModel(task.get('id'))

        moveUpdateData = @taskboardTasksService.move(task.id, usId, statusId, order)

        params = {
            status__is_archived: false,
            include_attachments: true,
        }

        options = {
            headers: {
                "set-orders": JSON.stringify(moveUpdateData.set_orders)
            }
        }

        promise = @repo.save(task, true, params, options, true).then (result) =>
            if result[0] and result[0].user_story
                @.reloadUserStory(result[0].user_story)

            @scope.movingTask = false
            headers = result[1]

            if headers && headers['taiga-info-order-updated']
                order = JSON.parse(headers['taiga-info-order-updated'])
                @taskboardTasksService.assignOrders(order)

            @.loadSprintStats()
            @.generateFilters()
            if @.isFilterDataTypeSelected('status')
                @.loadTasks()

    reloadUserStory: (userStoryId) ->
        @rs.userstories.get(@scope.project.id, userStoryId).then (us) =>
            @scope.userstories = _.map(@scope.userstories, (x) -> if x.id == us.id then us else x)

    ## Template actions
    addNewTask: (type, us) ->
        switch type
            when "standard" then @rootscope.$broadcast("genericform:new",
                {
                    'objType': 'task',
                    'project': @scope.project,
                    'sprintId': @scope.sprintId,
                    'usId': us?.id
                })
            when "bulk" then @rootscope.$broadcast("taskform:bulk", @scope.sprintId, us?.id)

    addNewIssue: (type, us) ->
        switch type
            when "standard" then @rootscope.$broadcast("genericform:new-or-existing",
                {
                    objType: 'issue',
                    project: @scope.project,
                    sprintId: @scope.sprintId,
                    relatedField: 'milestone',
                    relatedObjectId: @scope.sprintId,
                    targetName: @scope.sprint.name,
                })
            when "standard" then @rootscope.$broadcast("taskform:new", @scope.sprintId, us?.id)
            when "bulk" then @rootscope.$broadcast("issueform:bulk", @scope.projectId, @scope.sprintId)

    toggleFold: (id,  modelName) ->
        if modelName == 'issues'
            @taskboardIssuesService.toggleFold(id)
        else if modelName == 'tasks'
            @taskboardTasksService.toggleFold(id)

    openUsersSelection: (item) ->
        onClose = (assignedUsers) =>
            userId = assignedUsers.pop() || null

            if item.getName() == 'tasks'
                item.assigned_to = userId
                @taskboardTasksService.replaceModel(item)

                @repo.save(item).then =>
                    @.generateFilters()
                    if @.isFilterDataTypeSelected('assigned_to') || @.isFilterDataTypeSelected('role')
                        @.loadTasks()

            if item.getName() == 'issues'
                item.assigned_to = userId
                @taskboardIssuesService.replaceModel(item)

                @repo.save(item).then =>
                    @.generateFilters()
                    if @.isFilterDataTypeSelected('assigned_to') || @.isFilterDataTypeSelected('role')
                        @.loadIssues()

        @lightboxFactory.create(
            'tg-lb-select-user',
            {
                "class": "lightbox lightbox-select-user",
            },
            {
                "currentUsers": [item.assigned_to],
                "activeUsers": @scope.activeUsers,
                "onClose": onClose,
                "single": true,
                "lbTitle": @translate.instant("COMMON.ASSIGNED_USERS.ADD"),
            }
        )

    changeTaskAssignedTo: (id) ->
        task = @taskboardTasksService.getTaskModel(id)
        @.openUsersSelection(task)

    changeIssueAssignedTo: (id) ->
        issue = @taskboardIssuesService.getIssueModel(id)
        @.openUsersSelection(issue)

    setRolePoints: () ->
        computableRoles = _.filter(@scope.project.roles, "computable")

        getRole = (roleId) =>
            roleId = parseInt(roleId, 10)
            return _.find computableRoles, (role) -> role.id == roleId

        getPoint = (pointId) =>
            poitnId = parseInt(pointId, 10)
            return _.find @scope.project.points, (point) -> point.id == pointId

        pointsByRole = _.reduce @scope.userstories, (result, us, key) =>
            _.forOwn us.points, (pointId, roleId) ->
                role = getRole(roleId)
                point = getPoint(pointId) || { value: 0 }

                if role
                    if !result[role.id]
                        result[role.id] = role
                        result[role.id].points = 0

                    result[role.id].points += point.value

            return result
        , {}

        @scope.pointsByRole = Object.keys(pointsByRole).map (key) -> return pointsByRole[key]

    getIssuesOrderBy: ->
        if _.isString(@location.search().order_by)
            return @location.search().order_by
        else
            return "created_date"

module.controller("TaskboardController", TaskboardController)


#############################################################################
## TaskboardDirective
#############################################################################

TaskboardDirective = ($rootscope) ->
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        $el.on "click", ".toggle-analytics-visibility", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            target.toggleClass('active')
            $rootscope.$broadcast("taskboard:graph:toggle-visibility")

        tableBodyDom = $el.find('[data-js="taskboard-table-hscroll"]')
        tableBodyDom.on "scroll", (event) ->
            target = angular.element(event.currentTarget)
            tableHeaderDom = $el.find(".taskboard-table-inner")
            tableHeaderDom.css("left", -1 * target.scrollLeft())

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgTaskboard", ["$rootScope", TaskboardDirective])

#############################################################################
## Taskboard Squish Column Directive
#############################################################################

TaskboardSquishColumnDirective = (rs) ->
    gridGap = 5
    horizontalPadding = 32
    avatarWidth = 30
    maxColumnWidth = 292
    zoom0ColumnWidth = 182
    minWidth = avatarWidth + horizontalPadding
    maxRows = 3
    firstLoad = false

    link = ($scope, $el, $attrs) ->
        $scope.$watch "ctrl.zoom", () =>
            if firstLoad
                recalculateTaskboardWidth()

        $scope.$on "sprint:task:moved", () =>
            recalculateTaskboardWidth()

        $scope.$watch "usTasks", () ->
            if $scope.project
                $scope.statusesFolded = rs.tasks.getStatusColumnModes($scope.project.id)
                $scope.usFolded = rs.tasks.getUsRowModes($scope.project.id, $scope.sprintId)

                recalculateTaskboardWidth()

        $scope.foldStatus = (status) ->
            $scope.statusesFolded[status.id] = !!!$scope.statusesFolded[status.id]
            rs.tasks.storeStatusColumnModes($scope.projectId, $scope.statusesFolded)

            recalculateTaskboardWidth()

        $foldStatusArchived = (status) ->
            $scope.foldStatus(status)

        $scope.foldUs = (rowId) ->
            $scope.usFolded[rowId] = !!!$scope.usFolded[rowId]
            rs.tasks.storeUsRowModes($scope.projectId, $scope.sprintId, $scope.usFolded)

            recalculateTaskboardWidth()

        getCeilWidth = (usId, statusId) =>
            isStatusFolded = !!$scope.statusesFolded[statusId]
            isUSFolded = !!$scope.usFolded[usId]

            if usId
                tasks = $scope.usTasks.getIn([usId.toString(), statusId.toString()]).size
            else
                tasks = $scope.usTasks.getIn(['null', statusId.toString()]).size

            if tasks && (isUSFolded || isStatusFolded)
                if isUSFolded
                    columns = Math.ceil(tasks / maxRows)
                    width = avatarWidth * columns + ((columns - 1) * gridGap) + horizontalPadding
                else if isStatusFolded
                    width = avatarWidth
            else
                width = 0

            return width

        setStatusColumnWidth = (statusId, width) =>
            column = $el.find(".squish-status-#{statusId}")

            if width < minWidth
                width = minWidth

            column.css('max-width', width)
            return width

        recalculateStatusColumnWidth = (statusId) =>
            isStatusFolded = !!$scope.statusesFolded[statusId]
            initialWidth = 0

            if isStatusFolded
                initialWidth = avatarWidth
            else
                initialWidth = maxColumnWidth

                if Number($scope.ctrl.zoomLevel) == 0
                    initialWidth = zoom0ColumnWidth

            #unassigned ceil
            folded = !!$scope.statusesFolded[statusId]
            statusFoldedWidth = getCeilWidth(null, statusId)

            if statusFoldedWidth < initialWidth
                statusFoldedWidth = initialWidth

            _.forEach $scope.userstories, (us) ->
                isUSFolded = !!$scope.usFolded[us.id]
                width = getCeilWidth(us.id, statusId)

                statusFoldedWidth = width if width > statusFoldedWidth

            return setStatusColumnWidth(statusId, statusFoldedWidth)

        recalculateTaskboardWidth = () =>
            total = _.reduce $scope.taskStatusList, (acc, status) ->
                return acc + recalculateStatusColumnWidth(status.id) + 5
            , 0

            $el.find('.taskboard-table-inner').css("width", maxColumnWidth + total)
            if !firstLoad
                requestAnimationFrame () ->
                    $el.addClass('animations')

            firstLoad = true

            return

    return {link: link}

module.directive("tgTaskboardSquishColumn", ["$tgResources", TaskboardSquishColumnDirective])
