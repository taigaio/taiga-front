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
# File: modules/tasks/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy

module = angular.module("taigaTasks")

#############################################################################
## Task Detail Controller
#############################################################################

class TaskDetailController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "$log",
        "$appTitle",
        "$tgNavUrls",
        "$tgAnalytics",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @log, @appTitle, @navUrls, @analytics, tgLoader) ->
        @scope.taskRef = @params.taskref
        @scope.sectionName = "Task Details"
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set(@scope.task.subject + " - " + @scope.project.name)
            tgLoader.pageLoaded()

        promise.then null, @.onInitialDataError.bind(@)

    initializeEventHandlers: ->
        @scope.$on "attachment:create", =>
            @analytics.trackEvent("attachment", "create", "create attachment on task", 1)
            @rootscope.$broadcast("history:reload")
        @scope.$on "attachment:edit", =>
            @rootscope.$broadcast("history:reload")
        @scope.$on "attachment:delete", =>
            @rootscope.$broadcast("history:reload")

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.statusList = project.task_statuses
            @scope.statusById = groupBy(project.task_statuses, (x) -> x.id)
            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            return project

    loadTask: ->
        return @rs.tasks.get(@scope.projectId, @scope.taskId).then (task) =>
            @scope.task = task
            @scope.commentModel = task

            if @scope.task.neighbors.previous.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.task.neighbors.previous.ref
                }
                @scope.previousUrl = @navUrls.resolve("project-tasks-detail", ctx)

            if @scope.task.neighbors.next.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.task.neighbors.next.ref
                }
                @scope.nextUrl = @navUrls.resolve("project-tasks-detail", ctx)

            if task.milestone
                @rs.sprints.get(task.project, task.milestone).then (sprint) =>
                    @scope.sprint = sprint

            if task.user_story
                @rs.userstories.get(task.project, task.user_story).then (us) =>
                    @scope.us = us

    loadInitialData: ->
        params = {
            pslug: @params.pslug
            taskref: @params.taskref
        }

        promise = @repo.resolve(params).then (data) =>
            @scope.projectId = data.project
            @scope.taskId = data.task
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadTask())

module.controller("TaskDetailController", TaskDetailController)


#############################################################################
## Task status display directive
#############################################################################

TaskStatusDisplayDirective = ->
    # Display if a Task is open or closed and its taskboard status.
    #
    # Example:
    #     tg-task-status-display(ng-model="task")
    #
    # Requirements:
    #   - Task object (ng-model)
    #   - scope.statusById object

    template = _.template("""
    <span>
        <% if (status.is_closed) { %>
            Closed
        <% } else { %>
            Open
        <% } %>
    </span>
    <span class="us-detail-status" style="color:<%= status.color %>">
        <%= status.name %>
    </span>
    """) # TODO: i18n

    link = ($scope, $el, $attrs) ->
        render = (task) ->
            html = template({
                status: $scope.statusById[task.status]
            })
            $el.html(html)

        $scope.$watch $attrs.ngModel, (task) ->
            render(task) if task?

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgTaskStatusDisplay", TaskStatusDisplayDirective)


#############################################################################
## Task status button directive
#############################################################################

TaskStatusButtonDirective = ($rootScope, $repo, $confirm, $loading) ->
    # Display the status of Task and you can edit it.
    #
    # Example:
    #     tg-task-status-button(ng-model="task")
    #
    # Requirements:
    #   - Task object (ng-model)
    #   - scope.statusById object
    #   - $scope.project.my_permissions

    template = _.template("""
    <div class="status-data <% if(editable){ %>clickable<% }%>">
        <span class="level" style="background-color:<%= status.color %>"></span>
        <span class="status-status"><%= status.name %></span>
        <% if(editable){ %><span class="icon icon-arrow-bottom"></span><% }%>
        <span class="level-name">status</span>

        <ul class="popover pop-status">
            <% _.each(statuses, function(st) { %>
            <li><a href="" class="status" title="<%- st.name %>"
                   data-status-id="<%- st.id %>"><%- st.name %></a></li>
            <% }); %>
        </ul>
    </div>
    """) #TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_task") != -1

        render = (task) =>
            status = $scope.statusById[task.status]

            html = template({
                status: status
                statuses: $scope.statusList
                editable: isEditable()
            })
            $el.html(html)

        $el.on "click", ".status-data", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            $el.find(".pop-status").popover().open()

        $el.on "click", ".status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            target = angular.element(event.currentTarget)

            $.fn.popover().closeAll()

            task = $model.$modelValue.clone()
            task.status = target.data("status-id")
            $model.$setViewValue(task)

            $scope.$apply()

            onSuccess = ->
                $confirm.notify("success")
                $rootScope.$broadcast("history:reload")
                $loading.finish($el.find(".level-name"))

            onError = ->
                $confirm.notify("error")
                task.revert()
                $model.$setViewValue(task)
                $loading.finish($el.find(".level-name"))

            $loading.start($el.find(".level-name"))
            $repo.save($model.$modelValue).then(onSuccess, onError)

        $scope.$watch $attrs.ngModel, (task) ->
            render(task) if task

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgTaskStatusButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", TaskStatusButtonDirective])


TaskIsIocaineButtonDirective = ($rootscope, $tgrepo, $confirm, $loading) ->
    template = """
      <fieldset title="Feeling a bit overwhelmed by a task? Make sure others know about it by clicking on Iocaine when editing a task. It's possible to become immune to this (fictional) deadly poison by consuming small amounts over time just as it's possible to get better at what you do by occasionally taking on extra challenges!">
        <label for="is-iocaine" class="clickable button button-gray is-iocaine">Iocaine</label>
        <input type="checkbox" id="is-iocaine" name="is-iocaine"/>
      </fieldset>
    """

    link = ($scope, $el, $attrs, $model) ->
        $scope.$watch $attrs.ngModel, (task) ->
            return if not task

            if task.is_iocaine
                $el.find('.is-iocaine').addClass('active')
            else
                $el.find('.is-iocaine').removeClass('active')

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", ".is-iocaine", (event) ->
            task = $model.$modelValue.clone()
            task.is_iocaine = not task.is_iocaine
            $model.$setViewValue(task)
            $loading.start($el.find('label'))

            promise = $tgrepo.save($model.$modelValue)
            promise.then ->
                $confirm.notify("success")
                $rootscope.$broadcast("history:reload")

            promise.then null, ->
                $confirm.notify("error")

            promise.finally ->
                $loading.finish($el.find('label'))

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
        template: template
    }

module.directive("tgTaskIsIocaineButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", TaskIsIocaineButtonDirective])
