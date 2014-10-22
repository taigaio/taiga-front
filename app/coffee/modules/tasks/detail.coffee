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

        promise.then null, (xhr) =>
            if xhr and xhr.status == 404
                @location.path(@navUrls.resolve("not-found"))
                @location.replace()
            return @q.reject(xhr)

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

    block: ->
        @rootscope.$broadcast("block", @scope.task)

    unblock: ->
        @rootscope.$broadcast("unblock", @scope.task)

    delete: ->
        #TODO: i18n
        title = "Delete Task"
        message = @scope.task.subject

        @confirm.askOnDelete(title, message).then (finish) =>
            promise = @.repo.remove(@scope.task)
            promise.then =>
                finish()

                if @scope.task.milestone
                    @location.path(@navUrls.resolve("project-taskboard", {project: @scope.project.slug, sprint: @scope.sprint.slug}))
                else if @scope.us
                    @location.path(@navUrls.resolve("project-userstories-detail", {project: @scope.project.slug, ref: @scope.us.ref}))

            promise.then null, =>
                finish(false)
                @confirm.notify("error")

module.controller("TaskDetailController", TaskDetailController)


#############################################################################
## Task Main Directive
#############################################################################

TaskDirective = ($tgrepo, $log, $location, $confirm, $navUrls, $loading) ->
    linkSidebar = ($scope, $el, $attrs, $ctrl) ->

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSidebar($scope, $el, $attrs, $ctrl)

        if $el.is("form")
            form = $el.checksley()

        $el.on "click", ".save-task", (event) ->
            if not form.validate()
                return

            onSuccess = ->
                $loading.finish(target)
                $confirm.notify("success")
                ctx = {
                    project: $scope.project.slug
                    ref: $scope.task.ref
                }
                $location.path($navUrls.resolve("project-tasks-detail", ctx))

            onError = ->
                $loading.finish(target)
                $confirm.notify("error")

            target = angular.element(event.currentTarget)
            $loading.start(target)
            $tgrepo.save($scope.task).then(onSuccess, onError)

    return {link:link}

module.directive("tgTaskDetail", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", "$tgNavUrls",
                                  "$tgLoading", TaskDirective])


#############################################################################
## Task status directive
#############################################################################

TaskStatusDirective = () ->
    #TODO: i18n
    template = _.template("""
        <h1>
            <span>
            <% if (status.is_closed) { %>
            Closed
            <% } else { %>
            Open
            <% } %>
            <span class="us-detail-status" style="color:<%= status.color %>"><%= status.name %></span>
        </h1>
        <div class="us-created-by">
            <div class="user-avatar">
                <img src="<%= owner.photo %>" alt="<%- owner.full_name_display %>" />
            </div>

            <div class="created-by">
                <span class="created-title">Created by <%- owner.full_name_display %></span>
                <span class="created-date"><%- date %></span>
            </div>
        </div>
        <div class="issue-data">
            <div class="status-data <% if (editable) { %>clickable<% } %>">
                <span class="level" style="background-color:<%= status.color %>"></span>
                <span class="status-status"><%= status.name %></span>
                <% if (editable) { %>
                    <span class="icon icon-arrow-bottom"></span>
                <% } %>
                <span class="level-name">status</span>
            </div>
        </div>
    """)
    selectionStatusTemplate = _.template("""
      <ul class="popover pop-status">
          <% _.each(statuses, function(status) { %>
          <li><a href="" class="status" title="<%- status.name %>"
                 data-status-id="<%- status.id %>"><%- status.name %></a></li>
          <% }); %>
      </ul>
    """)

    link = ($scope, $el, $attrs, $model) ->
        editable = $attrs.editable?

        renderTaskstatus = (task) ->
            owner = $scope.usersById?[task.owner]
            date = moment(task.created_date).format("DD MMM YYYY HH:mm")
            status = $scope.statusById[task.status]
            html = template({
                owner: owner
                date: date
                editable: editable
                status: status
            })
            $el.html(html)
            $el.find(".status-data").append(selectionStatusTemplate({statuses:$scope.statusList}))

        $scope.$watch $attrs.ngModel, (task) ->
            if task?
                renderTaskstatus(task)

        if editable
            $el.on "click", ".status-data", (event) ->
                event.preventDefault()
                event.stopPropagation()
                $el.find(".pop-status").popover().open()

            $el.on "click", ".status", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                $model.$modelValue.status = target.data("status-id")
                renderTaskstatus($model.$modelValue)
                $el.find(".popover").popover().close()

    return {link:link, require:"ngModel"}

module.directive("tgTaskStatus", TaskStatusDirective)
