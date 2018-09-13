###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/taskboard.coffee
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
        "tgFilterRemoteStorageService"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @rs2, @params, @q, @appMetaService, @location, @navUrls,
                  @events, @analytics, @translate, @errorHandlingService, @taskboardTasksService,
                  @taskboardIssuesService, @storage, @filterRemoteStorageService) ->
        bindMethods(@)
        @taskboardTasksService.reset()
        @scope.userstories = []
        @.openFilter = false

        return if @.applyStoredFilters(@params.pslug, "tasks-filters")

        @scope.sectionName = @translate.instant("TASKBOARD.SECTION_NAME")
        @.initializeEventHandlers()

        taiga.defineImmutableProperty @.scope, "usTasks", () =>
            return @taskboardTasksService.usTasks

        taiga.defineImmutableProperty @.scope, "milestoneIssues", () =>
            return @taskboardIssuesService.milestoneIssues

    firstLoad: () ->
        promise = @.loadInitialData()

        # On Success
        promise.then => @._setMeta()
        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    setZoom: (zoomLevel, zoom) ->
        if @.zoomLevel == zoomLevel
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

        if @.zoomLevel == '0'
            @rootscope.$broadcast("sprint:zoom0")

    changeQ: (q) ->
        @.replaceFilter("q", q)
        @.loadTasks()
        @.generateFilters()

    removeFilter: (filter) ->
        @.unselectFilter(filter.dataType, filter.id)
        @.loadTasks()
        @.generateFilters()

    addFilter: (newFilter) ->
        @.selectFilter(newFilter.category.dataType, newFilter.filter.id)
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
        urlfilters = @location.search()
        filters.tags = urlfilters.tags
        filters.status = urlfilters.status
        filters.assigned_to = urlfilters.assigned_to
        filters.owner = urlfilters.owner
        filters.role = urlfilters.role

        @filterRemoteStorageService.getFilters(@scope.projectId, 'tasks-custom-filters').then (userFilters) =>
            userFilters[name] = filters

            @filterRemoteStorageService.storeFilters(@scope.projectId, userFilters, 'tasks-custom-filters').then(@.generateFilters)

    generateFilters: ->
        @.storeFilters(@params.pslug, @location.search(), "tasks-filters")

        urlfilters = @location.search()

        loadFilters = {}
        loadFilters.project = @scope.projectId
        loadFilters.milestone = @scope.sprintId
        loadFilters.tags = urlfilters.tags
        loadFilters.status = urlfilters.status
        loadFilters.assigned_to = urlfilters.assigned_to
        loadFilters.owner = urlfilters.owner
        loadFilters.role = urlfilters.role
        loadFilters.q = urlfilters.q

        return @q.all([
            @rs.tasks.filtersData(loadFilters),
            @filterRemoteStorageService.getFilters(@scope.projectId, 'tasks-custom-filters')
        ]).then (result) =>
            data = result[0]
            customFiltersRaw = result[1]

            statuses = _.map data.statuses, (it) ->
                it.id = it.id.toString()

                return it
            tags = _.map data.tags, (it) ->
                it.id = it.name

                return it

            tagsWithAtLeastOneElement = _.filter tags, (tag) ->
                return tag.count > 0

            assignedTo = _.map data.assigned_to, (it) ->
                if it.id
                    it.id = it.id.toString()
                else
                    it.id = "null"

                it.name = it.full_name || "Unassigned"

                return it
            role = _.map data.roles, (it) ->
                if it.id
                    it.id = it.id.toString()
                else
                    it.id = "null"

                it.name = it.name || "Unassigned"

                return it
            owner = _.map data.owners, (it) ->
                it.id = it.id.toString()
                it.name = it.full_name

                return it

            @.selectedFilters = []

            if loadFilters.status
                selected = @.formatSelectedFilters("status", statuses, loadFilters.status)
                @.selectedFilters = @.selectedFilters.concat(selected)

            if loadFilters.tags
                selected = @.formatSelectedFilters("tags", tags, loadFilters.tags)
                @.selectedFilters = @.selectedFilters.concat(selected)

            if loadFilters.assigned_to
                selected = @.formatSelectedFilters("assigned_to", assignedTo, loadFilters.assigned_to)
                @.selectedFilters = @.selectedFilters.concat(selected)

            if loadFilters.owner
                selected = @.formatSelectedFilters("owner", owner, loadFilters.owner)
                @.selectedFilters = @.selectedFilters.concat(selected)

            if loadFilters.role
                selected = @.formatSelectedFilters("role", role, loadFilters.role)
                @.selectedFilters = @.selectedFilters.concat(selected)

            @.filterQ = loadFilters.q

            @.filters = [
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.STATUS"),
                    dataType: "status",
                    content: statuses
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.TAGS"),
                    dataType: "tags",
                    content: tags,
                    hideEmpty: true,
                    totalTaggedElements: tagsWithAtLeastOneElement.length
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.ASSIGNED_TO"),
                    dataType: "assigned_to",
                    content: assignedTo
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.ROLE"),
                    dataType: "role",
                    content: role
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.CREATED_BY"),
                    dataType: "owner",
                    content: owner
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

            return sprint

    loadIssues: ->
        params = {}

        if @.zoomLevel > 1
            params.include_attachments = 1

        params = _.merge params, @location.search()

        return @rs.issues.listInProject(@scope.projectId, @scope.sprintId, params).then (issues) =>
            @taskboardIssuesService.init(@scope.project, @scope.usersById, @scope.issueStatusById)
            @taskboardIssuesService.set(issues)

    loadTasks: ->
        params = {}

        if @.zoomLevel > 1
            params.include_attachments = 1

        params = _.merge params, @location.search()
        return @rs.tasks.list(@scope.projectId, @scope.sprintId, null, params).then (tasks) =>
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
        params = {
            pslug: @params.pslug
            sslug: @params.sslug
        }

        promise = @repo.resolve(params).then (data) =>
            @scope.projectId = data.project
            @scope.sprintId = data.milestone
            @.initializeSubscription()
            return data

        return promise.then(=> @.loadProject())
                      .then =>
                          @.generateFilters()

                          return @.loadTaskboard().then(=> @.setRolePoints())

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
            message += " <strong>#{@scope.sprint.name}</strong>"

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
            headers = result[1]

            if headers && headers['taiga-info-order-updated']
                order = JSON.parse(headers['taiga-info-order-updated'])
                @taskboardTasksService.assignOrders(order)

            @.loadSprintStats()
            @.generateFilters()
            if @.isFilterDataTypeSelected('status')
                @.loadTasks()


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

    changeTaskAssignedTo: (id) ->
        task = @taskboardTasksService.getTaskModel(id)

        @rootscope.$broadcast("assigned-to:add", task)

    changeIssueAssignedTo: (id) ->
        issue = @taskboardIssuesService.getIssueModel(id)

        @rootscope.$broadcast("assigned-to:add", issue)

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
                point = getPoint(pointId)

                if !result[role.id]
                    result[role.id] = role
                    result[role.id].points = 0

                result[role.id].points += point.value

            return result
        , {}

        @scope.pointsByRole = Object.keys(pointsByRole).map (key) -> return pointsByRole[key]

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

        tableBodyDom = $el.find(".taskboard-table-body")
        tableBodyDom.on "scroll", (event) ->
            target = angular.element(event.currentTarget)
            tableHeaderDom = $el.find(".taskboard-table-header .taskboard-table-inner")
            tableHeaderDom.css("left", -1 * target.scrollLeft())

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgTaskboard", ["$rootScope", TaskboardDirective])

#############################################################################
## Taskboard Squish Column Directive
#############################################################################

TaskboardSquishColumnDirective = (rs) ->
    avatarWidth = 40
    maxColumnWidth = 300

    link = ($scope, $el, $attrs) ->
        $scope.$on "sprint:zoom0", () =>
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

        $scope.foldUs = (rowId) ->
            $scope.usFolded[rowId] = !!!$scope.usFolded[rowId]
            rs.tasks.storeUsRowModes($scope.projectId, $scope.sprintId, $scope.usFolded)

            recalculateTaskboardWidth()

        getCeilWidth = (usId, statusId) =>
            if usId
                tasks = $scope.usTasks.getIn([usId.toString(), statusId.toString()]).size
            else
                tasks = $scope.usTasks.getIn(['null', statusId.toString()]).size

            if $scope.statusesFolded[statusId]
                if tasks and $scope.usFolded[usId]
                    tasksMatrixSize = Math.round(Math.sqrt(tasks))
                    width = avatarWidth * tasksMatrixSize
                else
                    width = avatarWidth

                return width

            return 0

        setStatusColumnWidth = (statusId, width) =>
            column = $el.find(".squish-status-#{statusId}")

            if width
                column.css('max-width', width)
            else
                if $scope.ctrl.zoomLevel == '0'
                    column.css("max-width", 148)
                else
                    column.css("max-width", maxColumnWidth)

        refreshTaskboardTableWidth = () =>
            columnWidths = []

            columns = $el.find(".task-colum-name")

            columnWidths = _.map columns, (column) ->
                return $(column).outerWidth(true)

            totalWidth = _.reduce columnWidths, (total, width) ->
                return total + width

            $el.find('.taskboard-table-inner').css("width", totalWidth)

            issuesBoxWidth = $el.find('.issues-row .taskboard-row-title-box').outerWidth(true)
            $el.find('.issues-row').css("width", totalWidth - columnWidths.pop())

            issueCardMaxWidth = if $scope.ctrl.zoomLevel == '0' then 128 else 280
            $el.find('.issues-row .taskboard-cards-box .card').css("max-width", issueCardMaxWidth)

        recalculateStatusColumnWidth = (statusId) =>
            #unassigned ceil
            statusFoldedWidth = getCeilWidth(null, statusId)

            _.forEach $scope.userstories, (us) ->
                width = getCeilWidth(us.id, statusId)
                statusFoldedWidth = width if width > statusFoldedWidth

            setStatusColumnWidth(statusId, statusFoldedWidth)

        recalculateTaskboardWidth = () =>
            _.forEach $scope.taskStatusList, (status) ->
                recalculateStatusColumnWidth(status.id)

            refreshTaskboardTableWidth()

            return

    return {link: link}

module.directive("tgTaskboardSquishColumn", ["$tgResources", TaskboardSquishColumnDirective])
