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

class TaskDetailController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.AttachmentsMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$location",
        "$log",
        "$appTitle"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @log, @appTitle) ->
        @.attachmentsUrlName = "tasks/attachments"

        @scope.taskRef = @params.taskref
        @scope.sectionName = "Task Details"

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set(@scope.task.subject + " - " + @scope.project.name)

        promise.then null, ->
            console.log "FAIL" #TODO

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
            @scope.previousUrl = "/project/#{@scope.project.slug}/tasks/#{@scope.task.neighbors.previous.ref}" if @scope.task.neighbors.previous.id?
            @scope.nextUrl = "/project/#{@scope.project.slug}/tasks/#{@scope.task.neighbors.next.ref}" if @scope.task.neighbors.next.id?

    loadHistory: ->
        return @rs.tasks.history(@scope.taskId).then (history) =>
            _.each history.results, (historyResult) ->
                #If description was modified take only the description_html field
                if historyResult.values_diff.description?
                    historyResult.values_diff.description = historyResult.values_diff.description_diff

                if historyResult.values_diff.is_iocaine
                    historyResult.values_diff.is_iocaine = _.map(historyResult.values_diff.is_iocaine, (v) -> {true: 'Yes', false: 'No'}[v])

                delete historyResult.values_diff.description_html
                delete historyResult.values_diff.description_diff

            @scope.history = history.results
            @scope.comments = _.filter(history.results, (historyEntry) -> historyEntry.comment != "")

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
                      .then(=> @.loadAttachments(@scope.taskId))
                      .then(=> @.loadHistory())

    block: ->
        @rootscope.$broadcast("block", @scope.task)

    unblock: ->
        @rootscope.$broadcast("unblock", @scope.task)

    delete: ->
        #TODO: i18n
        title = "Delete Task"
        subtitle = @scope.task.subject

        @confirm.ask(title, subtitle).then =>
            @.repo.remove(@scope.task).then =>
                @location.path("/project/#{@scope.project.slug}/backlog")

module.controller("TaskDetailController", TaskDetailController)


#############################################################################
## Task Main Directive
#############################################################################

TaskDirective = ($tgrepo, $log, $location, $confirm) ->
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
                $confirm.notify("success")
                $location.path("/project/#{$scope.project.slug}/task/#{$scope.task.ref}")

            onError = ->
                $confirm.notify("error")

            $tgrepo.save($scope.task).then(onSuccess, onError)

        $el.on "click", ".add-comment a.button-green", (event) ->
            event.preventDefault()

            onSuccess = ->
                $ctrl.loadHistory()

            onError = ->
                $confirm.notify("error")

            $tgrepo.save($scope.task).then(onSuccess, onError)

        $el.on "focus", ".add-comment textarea", (event) ->
            $(this).addClass('active')

        $el.on "click", ".us-activity-tabs li a", (event) ->
            $el.find(".us-activity-tabs li a").toggleClass("active")
            $el.find(".us-activity section").toggleClass("hidden")

    return {link:link}

module.directive("tgTaskDetail", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", TaskDirective])


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
        <div class="issue-data">
            <div class="status-data <% if (editable) { %>clickable<% } %>">
                <span class="level" style="background-color:<%= status.color %>"></span>
                <span class="status-status"><%= status.name %></span>
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
            status = $scope.statusById[task.status]
            html = template({
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
