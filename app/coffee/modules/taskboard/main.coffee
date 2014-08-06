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
        "$q"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q) ->
        _.bindAll(@)

        @scope.sprintId = @params.id
        @scope.sectionName = "Taskboard"

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

        # TODO: Reload entire taskboard after create/edit tasks seems
        # a big overhead. It should be optimized in near future.
        @scope.$on("taskform:bulk:success", => @.loadTaskboard())
        @scope.$on("taskform:new:success", => @.loadTaskboard())
        @scope.$on("taskform:edit:success", => @.loadTaskboard())
        @scope.$on("taskboard:task:move", @.taskMove)

        @scope.$on "assigned-to:added", (ctx, userId, task) =>
            task.assigned_to = userId
            promise = @repo.save(task)
            promise.then null, ->
                console.log "FAIL" # TODO

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
            return stats

    loadSprint: ->
        return @rs.sprints.get(@scope.projectId, @scope.sprintId).then (sprint) =>
            @scope.sprint = sprint
            @scope.userstories = sprint.user_stories
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
                @scope.usTasks[task.user_story][task.status].push(task)

            return tasks

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

    loadTaskboard: ->
        return @q.all([
            @.loadSprintStats(),
            @.loadSprint()
        ]).then(=> @.loadTasks())

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
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

    editTask: (task) ->
        @rootscope.$broadcast("taskform:edit", task)

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
            toggleText(target, ["Hide statistics", "Show statistics"]) # TODO: i18n
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

TaskboardTaskDirective = ->
    link = ($scope, $el, $attrs) ->
        console.log "taskboard task"
        $el.disableSelection()

    return {link:link}


module.directive("tgTaskboardTask", TaskboardTaskDirective)


#############################################################################
## Taskboard Task Row Size Fixer Directive
#############################################################################

TaskboardRowSizeFixer = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "taskStatusList", (statuses) ->
            itemSize = 300 + (10 * statuses.length)
            size = (1 + statuses.length) * itemSize
            $el.css("width", "#{size}px")

    return {link: link}

module.directive("tgTaskboardRowSizeFixer", TaskboardRowSizeFixer)

#############################################################################
## Taskboard User Directive
#############################################################################

TaskboardUserDirective = ($log) ->
    template = _.template("""
    <figure class="avatar">
        <a href="#" title="<%- name %>">
            <img src="<%= imgurl %>" alt="<%- name %>">
            <figcaption><%- name %></figcaption>
        </a>
    </figure>
    """)

    uniqueId = _.uniqueId("user_photo")

    link = ($scope, $el, $attrs) ->
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
                ctx = {name: "Unassigned", imgurl: "/images/unnamed.png"}
            else
                ctx = {name: user.full_name_display, imgurl: user.photo}

            html = template(ctx)
            $el.off(".#{uniqueId}")
            $el.html(html)

            $el.on "click.#{uniqueId}", "figure.avatar > a", (event) ->
                if not $attrs.click?
                    return $log.error "TaskboardUserDirective: No click attr is defined."

                $scope.$apply ->
                    $scope.$eval($attrs.click)

    return {link: link}


module.directive("tgTaskboardUserAvatar", ["$log", TaskboardUserDirective])
