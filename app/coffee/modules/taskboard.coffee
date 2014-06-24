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

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL"

    loadSprintStats: ->
        return @rs.sprints.stats(@scope.projectId, @scope.sprintId).then (stats) =>
            console.log "loadSprintStats",
            @scope.stats = stats
            return stats

    loadSprint: ->
        return @rs.sprints.get(@scope.projectId, @scope.sprintId).then (sprint) =>
            console.log "loadSprint", sprint
            @scope.sprint = sprint
            @scope.userstories = sprint.user_stories
            return sprint

    loadTasks: ->
        return @rs.tasks.list(@scope.projectId, @scope.sprintId).then (tasks) =>
            @scope.tasks = tasks
            @scope.tasksByStatus = _.groupBy(tasks, "status")
            console.log "loadTasks", @scope.tasksByStatus
            return tasks

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.points = _.sortBy(project.points, "order")
            @scope.statusList = _.sortBy(project.task_statuses, "id")
            console.log "loadProject", @scope.statusList
            return project

    loadTaskboard: ->
        return @q.all([
            @.loadSprintStats(),
            @.loadSprint()
            # @.loadTasks(),
        ]).then(=> @.loadTasks())

    loadInitialData: ->
        console.log @params
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadTaskboard())
#############################################################################
## TaskboardDirective
#############################################################################

TaskboardDirective = ->

    #########################
    ## Drag & Drop Link
    #########################

    linkSortable = ($scope, $el, $attrs, $ctrl) ->
        console.log "TaskboardDirective:linkSortable"

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSortable($scope, $el, $attrs, $ctrl)
        # linkCommon($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module = angular.module("taigaTaskboard", [])
module.controller("TaskboardController", TaskboardController)
module.directive("tgTaskboard", TaskboardDirective)
