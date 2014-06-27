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
mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce

module = angular.module("taigaTaskboard", [])

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
            @scope.tasksByStatus = _.groupBy(tasks, "status")
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
            # @.loadTasks(),
        ]).then(=> @.loadTasks())

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadTaskboard())

module.controller("TaskboardController", TaskboardController)


#############################################################################
## TaskboardDirective
#############################################################################

TaskboardDirective = ->

    #########################
    ## Drag & Drop Link
    #########################

    linkSortable = ($scope, $el, $attrs, $ctrl) ->
        console.log "TaskboardDirective.linkSortable" #TODO

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSortable($scope, $el, $attrs, $ctrl)

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


module.directive("tgTaskboard", TaskboardDirective)
module.directive("tgTaskboardRowSizeFixer", TaskboardRowSizeFixer)
module.directive("tgTaskboardUsPoints", ["$tgRepo", "$tgConfirm", TaskboardUsPointsDirective])
