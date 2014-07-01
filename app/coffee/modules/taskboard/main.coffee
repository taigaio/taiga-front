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
        @scope.sprintId = @params.id
        @scope.sectionName = "Taskboard"

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

        @scope.$on "taskform:new:success", =>
            @.loadTaskboard()
        @scope.$on "taskform:bulk:success", =>
            @.loadTaskboard()
        @scope.$on "taskform:edit:success", =>
            @.loadTaskboard()

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
            @scope.unassignedTasks = {}

            for us in @scope.userstories
                @scope.usTasks[us.id] = {}

                for status in @scope.taskStatusList
                    @scope.usTasks[us.id][status.id] = []

            for status in @scope.taskStatusList
                @scope.unassignedTasks[status.id] = []

            for task in @scope.tasks
                if task.user_story == null
                    @scope.unassignedTasks[task.status]?.push(task)
                else
                    # why? because a django-filters sucks
                    if @scope.usTasks[task.user_story]?
                        @scope.usTasks[task.user_story][task.status]?.push(task)

            return tasks

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project

            @scope.pointsList = _.sortBy(project.points, "order")
            @scope.pointsById = groupBy(@scope.pointsList, (e) -> e.id)

            @scope.roleList = _.sortBy(project.roles, "order")
            @scope.roleById = groupBy(@scope.roleList, (e) -> e.id)

            @scope.taskStatusList = _.sortBy(project.task_statuses, "order")

            @scope.usStatusList = _.sortBy(project.us_statuses, "order")
            @scope.usStatusById = groupBy(@scope.usStatusList, (e) -> e.id)

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

    ## Template actions

    addNewTask: (type, us) ->
        switch type
            when "standard" then @rootscope.$broadcast("taskform:new", @scope.sprintId, us?.id)
            when "bulk" then @rootscope.$broadcast("taskform:bulk", us.id)

    editTask: (task) ->
        @rootscope.$broadcast("taskform:edit", task)

module.controller("TaskboardController", TaskboardController)


#############################################################################
## TaskboardDirective
#############################################################################

TaskboardDirective = ($rootscope) ->

    #########################
    ## Drag & Drop Link
    #########################

    linkSortable = ($scope, $el, $attrs, $ctrl) ->
        onUpdateItem = (event) ->
            #TODO
            console.log "onUpdate", event

        onAddItem = (event) ->
            #TODO
            console.log "onAddItem", event

        onRemoveItem = (event) ->
            #TODO
            console.log "onRemoveItem", event

        dom = $el.find(".taskboard-table-body")
        sortable = new Sortable(dom[0], {
            group: "taskboard",
            selector: ".taskboard-task",
            onUpdate: onUpdateItem
            onAdd: onAddItem
            onRemove: onRemoveItem
        })

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSortable($scope, $el, $attrs, $ctrl)

        $el.on "click", ".toggle-analytics-visibility", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            toggleText(target, ["Hide statistics", "Show statistics"]) # TODO: i18n
            $rootscope.$broadcast("taskboard:graph:toggle-visibility")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


#############################################################################
## Task Row Size Fixer Directive
#############################################################################

TaskboardRowSizeFixer = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "taskStatusList", (statuses) ->
            itemSize = 300 + (10 * statuses.length)
            size = (1 + statuses.length) * itemSize
            $el.css("width", size + "px")

    return {link: link}


TaskboardUsPointsDirective = ($repo, $confirm) ->
    pointsTemplate = _.template("""
    <% _.each(usRolePoints, function(rolePoint) { %>
    <li>
        <%- rolePoint.role.name %> <span class="us-role-points"> <%- rolePoint.point.name %></span>
        <ul class="popover pop-points">
            <% _.each(points, function(point) { %>
            <li>
                <a href="" class="point" title="<%- point.name %>"
                   data-point-id="<%- point.id %>" data-role-id="<%- rolePoint.role.id %>">
                    <%- point.name %>
                </a>
            </li>
            <% }); %>
        </ul>
    </li>
    <% }); %>
    """)
    renderUserStoryPoints = ($el, $scope, us) ->
        points = $scope.pointsList
        usRolePoints = []

        for role_id, point_id of us.points
            role = $scope.roleById[role_id]
            point = $scope.pointsById[point_id]
            if role and point
                usRolePoints.push({role: role, point: point})

        bindOnce $scope, "project", (project) ->
            html = pointsTemplate({
                points: points
                usRolePoints: usRolePoints
            })
            $el.html(html)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        us = $scope.$eval($attrs.tgTaskboardUsPoints)
        renderUserStoryPoints($el, $scope, us)

        $el.on "click", ".us-role-points", (event) ->
            event.stopPropagation()

            target = angular.element(event.currentTarget)
            popover = target.parent().find(".pop-points")
            popover.show()

            body = angular.element("body")
            body.one "click", (event) ->
                popover.hide()

        $el.on "click", ".point", (event) ->
            event.preventDefault()
            event.stopPropagation()

            target = angular.element(event.currentTarget)
            roleId = target.data("role-id")
            pointId = target.data("point-id")
            newPoints = _.clone(us.points, false)
            newPoints[roleId] = pointId
            us.points = newPoints

            $el.find(".pop-points").hide()

            $scope.$apply ->
                onSuccess = ->
                    $repo.refresh(us) ->
                        # TODO: Remove me when backlog will be fixed
                        $ctrl.loadSprintStats()

                onError = ->
                    $confirm.notify("error", "There is an error. Try it later.")
                    us.revert()
                    renderUserStoryPoints($el, $scope, us)

                renderUserStoryPoints($el, $scope, us)
                $repo.save(us).then(onSuccess, onError)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


#############################################################################
## Sprint burndown graph directive
#############################################################################

SprintGraphDirective = ->
    redrawChart = (element, dataToDraw) ->
        width = element.width()
        element.height(240)

        days = _.map(dataToDraw, (x) -> moment(x.day))

        data = []
        data.unshift({
            data: _.zip(days, _.map(dataToDraw, (d) -> d.optimal_points))
            lines:
                fillColor : "rgba(120,120,120,0.2)"
        })
        data.unshift({
            data: _.zip(days, _.map(dataToDraw, (d) -> d.open_points))
            lines:
                fillColor : "rgba(102,153,51,0.3)"
        })

        options =
            grid:
                borderWidth: { top: 0, right: 1, left:0, bottom: 0 }
                borderColor: '#ccc'
            xaxis:
                tickSize: [1, "day"]
                min: days[0]
                max: _.last(days)
                mode: "time"
                daysNames: days
                axisLabel: 'Day'
                axisLabelUseCanvas: true
                axisLabelFontSizePixels: 12
                axisLabelFontFamily: 'Verdana, Arial, Helvetica, Tahoma, sans-serif'
                axisLabelPadding: 5
            yaxis:
                min: 0
            series:
                shadowSize: 0
                lines:
                    show: true
                    fill: true
                points:
                    show: true
                    fill: true
                    radius: 4
                    lineWidth: 2
            colors: ["rgba(102,153,51,1)", "rgba(120,120,120,0.2)"]

        element.empty()
        element.plot(data, options).data("plot")

    link = ($scope, $el, $attrs) ->
        element = angular.element($el)
        $scope.$watch 'stats', (value) ->
            if $scope.stats?
                redrawChart(element, $scope.stats.days)

                $scope.$on "resize", ->
                    redrawChart(element, $scope.stats.days)

                $scope.$on "taskboard:graph:toggle-visibility", ->
                    $el.toggle()

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgTaskboard", ["$rootScope", TaskboardDirective])
module.directive("tgTaskboardRowSizeFixer", TaskboardRowSizeFixer)
module.directive("tgTaskboardUsPoints", ["$tgRepo", "$tgConfirm", TaskboardUsPointsDirective])
module.directive("tgSprintGraph", SprintGraphDirective)
