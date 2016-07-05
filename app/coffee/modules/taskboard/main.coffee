###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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

module = angular.module("taigaTaskboard")


#############################################################################
## Taskboard Controller
#############################################################################

class TaskboardController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "tgAppMetaService",
        "$tgLocation",
        "$tgNavUrls"
        "$tgEvents"
        "$tgAnalytics",
        "$translate",
        "tgErrorHandlingService"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @appMetaService, @location, @navUrls,
                  @events, @analytics, @translate, @errorHandlingService) ->
        bindMethods(@)

        @scope.sectionName = @translate.instant("TASKBOARD.SECTION_NAME")
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then => @._setMeta()
        # On Error
        promise.then null, @.onInitialDataError.bind(@)

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
        # TODO: Reload entire taskboard after create/edit tasks seems
        # a big overhead. It should be optimized in near future.
        @scope.$on "taskform:bulk:success", =>
            @.loadTaskboard()
            @analytics.trackEvent("task", "create", "bulk create task on taskboard", 1)

        @scope.$on "taskform:new:success", =>
            @.loadTaskboard()
            @analytics.trackEvent("task", "create", "create task on taskboard", 1)

        @scope.$on("taskform:edit:success", => @.loadTaskboard())
        @scope.$on("taskboard:task:move", @.taskMove)

        @scope.$on "assigned-to:added", (ctx, userId, task) =>
            task.assigned_to = userId
            promise = @repo.save(task)
            promise.then null, ->
                console.log "FAIL" # TODO

    initializeSubscription: ->
        routingKey = "changes.project.#{@scope.projectId}.tasks"
        @events.subscribe @scope, routingKey, (message) =>
            @.loadTaskboard()

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
            # @scope.roleList = _.sortBy(project.roles, "order")
            @scope.pointsById = groupBy(project.points, (e) -> e.id)
            @scope.roleById = groupBy(project.roles, (e) -> e.id)
            @scope.taskStatusList = _.sortBy(project.task_statuses, "order")
            @scope.usStatusList = _.sortBy(project.us_statuses, "order")
            @scope.usStatusById = groupBy(project.us_statuses, (e) -> e.id)

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
            @scope.project.tags_colors = tags_colors

    loadSprint: ->
        return @rs.sprints.get(@scope.projectId, @scope.sprintId).then (sprint) =>
            @scope.sprint = sprint
            @scope.userstories = _.sortBy(sprint.user_stories, "sprint_order")
            return sprint

    loadTasks: ->
        return @rs.tasks.list(@scope.projectId, @scope.sprintId).then (tasks) =>
            @scope.tasks = _.sortBy(tasks, 'taskboard_order')
            @scope.usTasks = {}

            # Iterate over all userstories and
            # null userstory for unassigned tasks
            for us in _.union(@scope.userstories, [{id:null}])
                @scope.usTasks[us.id] = {}
                for status in @scope.taskStatusList
                    @scope.usTasks[us.id][status.id] = []

            for task in @scope.tasks
                if @scope.usTasks[task.user_story]? and @scope.usTasks[task.user_story][task.status]?
                    @scope.usTasks[task.user_story][task.status].push(task)

            if tasks.length == 0

                if @scope.userstories.length > 0
                    usId = @scope.userstories[0].id
                else
                    usId = null

                @scope.usTasks[usId][@scope.taskStatusList[0].id].push({isPlaceholder: true})

            return tasks

    loadTaskboard: ->
        return @q.all([
            @.refreshTagsColors(),
            @.loadSprintStats(),
            @.loadSprint().then(=> @.loadTasks())
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
                      .then(=> @.loadTaskboard())
                      .then(=> @.setRolePoints())

    refreshTasksOrder: (tasks) ->
            items = @.resortTasks(tasks)
            data = @.prepareBulkUpdateData(items)

            return @rs.tasks.bulkUpdateTaskTaskboardOrder(@scope.project.id, data)

    resortTasks: (tasks) ->
        items = []

        for item, index in tasks
            item["taskboard_order"] = index
            if item.isModified()
                items.push(item)

        return items

    prepareBulkUpdateData: (uses) ->
         return _.map(uses, (x) -> {"task_id": x.id, "order": x["taskboard_order"]})

    taskMove: (ctx, task, usId, statusId, order) ->
        # Remove task from old position
        r = @scope.usTasks[task.user_story][task.status].indexOf(task)
        @scope.usTasks[task.user_story][task.status].splice(r, 1)

        # Add task to new position
        tasks = @scope.usTasks[usId][statusId]
        tasks.splice(order, 0, task)

        task.user_story = usId
        task.status = statusId
        task.taskboard_order = order

        promise = @repo.save(task)

        @rootscope.$broadcast("sprint:task:moved", task)

        promise.then =>
            @.refreshTasksOrder(tasks)
            @.loadSprintStats()

        promise.then null, =>
            console.log "FAIL TASK SAVE"

    ## Template actions
    addNewTask: (type, us) ->
        switch type
            when "standard" then @rootscope.$broadcast("taskform:new", @scope.sprintId, us?.id)
            when "bulk" then @rootscope.$broadcast("taskform:bulk", @scope.sprintId, us?.id)

    editTaskAssignedTo: (task) ->
        @rootscope.$broadcast("assigned-to:add", task)

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
## Taskboard Task Directive
#############################################################################

TaskboardTaskDirective = ($rootscope, $loading, $rs, $rs2) ->
    link = ($scope, $el, $attrs, $model) ->
        $scope.$watch "task", (task) ->
            if task.is_blocked and not $el.hasClass("blocked")
                $el.addClass("blocked")
            else if not task.is_blocked and $el.hasClass("blocked")
                $el.removeClass("blocked")

        $el.find(".edit-task").on "click", (event) ->
            if $el.find('.edit-task').hasClass('noclick')
                return

            $scope.$apply ->
                target = $(event.target)

                currentLoading = $loading()
                    .target(target)
                    .timeout(200)
                    .start()

                task = $scope.task

                $rs.tasks.getByRef(task.project, task.ref).then (editingTask) =>
                    $rs2.attachments.list("task", editingTask.id, editingTask.project).then (attachments) =>
                        $rootscope.$broadcast("taskform:edit", editingTask, attachments.toJS())
                        currentLoading.finish()

    return {link:link}


module.directive("tgTaskboardTask", ["$rootScope", "$tgLoading", "$tgResources", "tgResources", TaskboardTaskDirective])

#############################################################################
## Taskboard Squish Column Directive
#############################################################################

TaskboardSquishColumnDirective = (rs) ->
    avatarWidth = 40
    maxColumnWidth = 300

    link = ($scope, $el, $attrs) ->
        $scope.$on "sprint:task:moved", () =>
            recalculateTaskboardWidth()

        bindOnce $scope, "usTasks", (project) ->
            $scope.statusesFolded = rs.tasks.getStatusColumnModes($scope.project.id)
            $scope.usFolded = rs.tasks.getUsRowModes($scope.project.id, $scope.sprintId)

            recalculateTaskboardWidth()

        $scope.foldStatus = (status) ->
            $scope.statusesFolded[status.id] = !!!$scope.statusesFolded[status.id]
            rs.tasks.storeStatusColumnModes($scope.projectId, $scope.statusesFolded)

            recalculateTaskboardWidth()

        $scope.foldUs = (us) ->
            if !us
                $scope.usFolded[null] = !!!$scope.usFolded[null]
            else
                $scope.usFolded[us.id] = !!!$scope.usFolded[us.id]

            rs.tasks.storeUsRowModes($scope.projectId, $scope.sprintId, $scope.usFolded)

            recalculateTaskboardWidth()

        getCeilWidth = (usId, statusId) =>
            tasks = $scope.usTasks[usId][statusId].length

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
                column.css("max-width", maxColumnWidth)

        refreshTaskboardTableWidth = () =>
            columnWidths = []

            columns = $el.find(".task-colum-name")

            columnWidths = _.map columns, (column) ->
                return $(column).outerWidth(true)

            totalWidth = _.reduce columnWidths, (total, width) ->
                return total + width

            $el.find('.taskboard-table-inner').css("width", totalWidth)

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

#############################################################################
## Taskboard User Directive
#############################################################################

TaskboardUserDirective = ($log, $translate) ->
    clickable = false

    link = ($scope, $el, $attrs) ->
        username_label = $el.parent().find("a.task-assigned")
        username_label.addClass("not-clickable")

        $scope.$watch 'task.assigned_to', (assigned_to) ->
            user = $scope.usersById[assigned_to]

            if user is undefined
                _.assign($scope, {
                    name: $translate.instant("COMMON.ASSIGNED_TO.NOT_ASSIGNED"),
                    imgurl: "/#{window._version}/images/unnamed.png",
                    clickable: clickable
                })
            else
                _.assign($scope, {
                    name: user.full_name_display,
                    imgurl: user.photo,
                    clickable: clickable
                })

            username_label.text($scope.name)


        bindOnce $scope, "project", (project) ->
            if project.my_permissions.indexOf("modify_task") > -1
                clickable = true
                $el.find(".avatar-assigned-to").on "click", (event) =>
                    if $el.find('a').hasClass('noclick')
                        return

                    $ctrl = $el.controller()
                    $ctrl.editTaskAssignedTo($scope.task)

                username_label.removeClass("not-clickable")
                username_label.on "click", (event) ->
                    if $el.find('a').hasClass('noclick')
                        return

                    $ctrl = $el.controller()
                    $ctrl.editTaskAssignedTo($scope.task)


    return {
        link: link,
        templateUrl: "taskboard/taskboard-user.html",
        scope: {
            "usersById": "=users",
            "project": "=",
            "task": "=",
        }
    }


module.directive("tgTaskboardUserAvatar", ["$log", "$translate", TaskboardUserDirective])
