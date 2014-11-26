###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
        "$appTitle",
        "$tgLocation",
        "$tgNavUrls"
        "$tgEvents"
        "$tgAnalytics",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @appTitle, @location, @navUrls,
                  @events, @analytics, tgLoader) ->
        bindMethods(@)

        @scope.sectionName = "Taskboard"
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set("Taskboard - " + @scope.project.name)
            tgLoader.pageLoaded()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

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
            @scope.project = project
            @scope.$emit('project:loaded', project)
            # Not used at this momment
            @scope.pointsList = _.sortBy(project.points, "order")
            # @scope.roleList = _.sortBy(project.roles, "order")
            @scope.pointsById = groupBy(project.points, (e) -> e.id)
            @scope.roleById = groupBy(project.roles, (e) -> e.id)
            @scope.taskStatusList = _.sortBy(project.task_statuses, "order")
            @scope.usStatusList = _.sortBy(project.us_statuses, "order")
            @scope.usStatusById = groupBy(project.us_statuses, (e) -> e.id)
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
                @scope.stats.completedPercentage = Math.round(100 * stats.completedPointsSum / stats.totalPointsSum)
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
            @scope.tasks = tasks
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
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadTaskboard())

    taskMove: (ctx, task, usId, statusId, order) ->
        # Remove task from old position
        r = @scope.usTasks[task.user_story][task.status].indexOf(task)
        @scope.usTasks[task.user_story][task.status].splice(r, 1)

        # Add task to new position
        @scope.usTasks[usId][statusId].splice(order, 0, task)

        task.user_story = usId
        task.status = statusId
        task.order = order

        promise = @repo.save(task)
        promise.then =>
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
            target.toggleClass('active');
            #toggleText(target, ["Hide statistics", "Show statistics"]) # TODO: i18n
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

TaskboardTaskDirective = ($rootscope) ->
    link = ($scope, $el, $attrs, $model) ->
        $el.disableSelection()

        $scope.$watch "task", (task) ->
            if task.is_blocked and not $el.hasClass("blocked")
                $el.addClass("blocked")
            else if not task.is_blocked and $el.hasClass("blocked")
                $el.removeClass("blocked")

        $el.find(".icon-edit").on "click", (event) ->
            if $el.find('.icon-edit').hasClass('noclick')
                return
            $scope.$apply ->
                $rootscope.$broadcast("taskform:edit", $scope.task)

    return {link:link}


module.directive("tgTaskboardTask", ["$rootScope", TaskboardTaskDirective])


#############################################################################
## Taskboard Task Row Size Fixer Directive
#############################################################################

TaskboardRowWidthFixerDirective = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "taskStatusList", (statuses) ->
            itemSize = 300 + (10 * statuses.length)
            size = (1 + statuses.length) * itemSize
            $el.css("width", "#{size}px")

    return {link: link}

module.directive("tgTaskboardRowWidthFixer", TaskboardRowWidthFixerDirective)

#############################################################################
## Taskboard Table Height Fixer Directive
#############################################################################

TaskboardTableHeightFixerDirective = ->
    mainPadding = 32 # px

    renderSize = ($el) ->
        elementOffset = $el.offset().top
        windowHeight = angular.element(window).height()
        columnHeight = windowHeight - elementOffset - mainPadding
        $el.css("height", "#{columnHeight}px")

    link = ($scope, $el, $attrs) ->
        timeout(500, -> renderSize($el))

        $scope.$on "resize", ->
            renderSize($el)

    return {link:link}


module.directive("tgTaskboardTableHeightFixer", TaskboardTableHeightFixerDirective)


#############################################################################
## Taskboard User Directive
#############################################################################

TaskboardUserDirective = ($log) ->
    template = _.template("""
    <figure class="avatar">
        <a href="#" title="Assign task" <% if (!clickable) {%>class="not-clickable"<% } %>>
            <img src="<%- imgurl %>" alt="<%- name %>">
        </a>
    </figure>
    """) # TODO: i18n

    clickable = false

    link = ($scope, $el, $attrs, $model) ->
        if not $attrs.tgTaskboardUserAvatar?
            return $log.error "TaskboardUserDirective: no attr is defined"

        wtid = $scope.$watch $attrs.tgTaskboardUserAvatar, (v) ->
            if not $scope.usersById?
                $log.error "TaskboardUserDirective requires userById set in scope."
                wtid()
            else
                user = $scope.usersById[v]
                render(user)

        render = (user) ->
            if user is undefined
                ctx = {name: "Unassigned", imgurl: "/images/unnamed.png", clickable: clickable}
            else
                ctx = {name: user.full_name_display, imgurl: user.photo, clickable: clickable}

            html = template(ctx)
            $el.html(html)
            username_label = $el.parent().find("a.task-assigned")
            username_label.html(ctx.name)
            username_label.on "click", (event) ->
                if $el.find('a').hasClass('noclick')
                    return

                us = $model.$modelValue
                $ctrl = $el.controller()
                $ctrl.editTaskAssignedTo(us)

        bindOnce $scope, "project", (project) ->
            if project.my_permissions.indexOf("modify_task") > -1
                clickable = true
                $el.on "click", (event) =>
                    if $el.find('a').hasClass('noclick')
                        return

                    us = $model.$modelValue
                    $ctrl = $el.controller()
                    $ctrl.editTaskAssignedTo(us)

    return {link: link, require:"ngModel"}


module.directive("tgTaskboardUserAvatar", ["$log", TaskboardUserDirective])
