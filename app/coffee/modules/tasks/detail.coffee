###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
bindMethods = @.taiga.bindMethods

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
        "tgAppMetaService",
        "$tgNavUrls",
        "$tgAnalytics",
        "$translate",
        "$tgQueueModelTransformation",
        "tgErrorHandlingService",
        "tgProjectService"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @log, @appMetaService, @navUrls, @analytics, @translate, @modelTransform, @errorHandlingService, @projectService) ->
        bindMethods(@)

        @scope.taskRef = @params.taskref
        @scope.sectionName = @translate.instant("TASK.SECTION_NAME")
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        promise.then () =>
            @._setMeta()
            @.initializeOnDeleteGoToUrl()

        promise.then null, @.onInitialDataError.bind(@)

    _setMeta: ->
        title = @translate.instant("TASK.PAGE_TITLE", {
            taskRef: "##{@scope.task.ref}"
            taskSubject: @scope.task.subject
            projectName: @scope.project.name
        })
        description = @translate.instant("TASK.PAGE_DESCRIPTION", {
            taskStatus: @scope.statusById[@scope.task.status]?.name or "--"
            taskDescription: angular.element(@scope.task.description_html or "").text()
        })
        @appMetaService.setAll(title, description)

    initializeEventHandlers: ->
        @scope.$on "attachment:create", =>
            @analytics.trackEvent("attachment", "create", "create attachment on task", 1)
        @scope.$on "custom-attributes-values:edit", =>
            @rootscope.$broadcast("object:updated")
        @scope.$on "comment:new", =>
            @.loadTask()

    initializeOnDeleteGoToUrl: ->
        ctx = {project: @scope.project.slug}
        @scope.onDeleteGoToUrl = @navUrls.resolve("project", ctx)
        if @scope.project.is_backlog_activated
            if @scope.task.milestone
                ctx.sprint = @scope.sprint.slug
                @scope.onDeleteGoToUrl = @navUrls.resolve("project-taskboard", ctx)
            else if @scope.task.us
                ctx.ref = @scope.us.ref
                @scope.onDeleteGoToUrl = @navUrls.resolve("project-userstories-detail", ctx)
        else if @scope.project.is_kanban_activated
            if @scope.us
                ctx.ref = @scope.us.ref
                @scope.onDeleteGoToUrl = @navUrls.resolve("project-userstories-detail", ctx)

    loadProject: ->
        project = @projectService.project.toJS()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)
        @scope.statusList = project.task_statuses
        @scope.statusById = groupBy(project.task_statuses, (x) -> x.id)
        return project

    loadTask: ->
        return @rs.tasks.getByRef(@scope.projectId, @params.taskref).then (task) =>
            @scope.task = task
            @scope.taskId = task.id
            @scope.commentModel = task

            @modelTransform.setObject(@scope, 'task')

            if @scope.task.neighbors.previous?.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.task.neighbors.previous.ref
                }
                @scope.previousUrl = @navUrls.resolve("project-tasks-detail", ctx)

            if @scope.task.neighbors.next?.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.task.neighbors.next.ref
                }
                @scope.nextUrl = @navUrls.resolve("project-tasks-detail", ctx)
            return task

    loadSprint: ->
        if @scope.task.milestone
            return @rs.sprints.get(@scope.task.project, @scope.task.milestone).then (sprint) =>
                @scope.sprint = sprint
                return sprint

    loadUserStory: ->
        if @scope.task.user_story
            return @rs.userstories.get(@scope.task.project, @scope.task.user_story).then (us) =>
                @scope.us = us
                return us

    loadInitialData: ->
        project = @.loadProject()

        @.fillUsersAndRoles(project.members, project.roles)
        return @.loadTask().then(=> @q.all([@.loadSprint(), @.loadUserStory()]))

    ###
    # Note: This methods (onUpvote() and onDownvote()) are related to tg-vote-button.
    #       See app/modules/components/vote-button for more info
    ###
    onUpvote: ->
        onSuccess = =>
            @.loadTask()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.tasks.upvote(@scope.taskId).then(onSuccess, onError)

    onDownvote: ->
        onSuccess = =>
            @.loadTask()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.tasks.downvote(@scope.taskId).then(onSuccess, onError)

    ###
    # Note: This methods (onWatch() and onUnwatch()) are related to tg-watch-button.
    #       See app/modules/components/watch-button for more info
    ###
    onWatch: ->
        onSuccess = =>
            @.loadTask()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.tasks.watch(@scope.taskId).then(onSuccess, onError)

    onUnwatch: ->
        onSuccess = =>
            @.loadTask()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.tasks.unwatch(@scope.taskId).then(onSuccess, onError)

module.controller("TaskDetailController", TaskDetailController)


#############################################################################
## Task status display directive
#############################################################################

TaskStatusDisplayDirective = ($template, $compile) ->
    # Display if a Task is open or closed and its taskboard status.
    #
    # Example:
    #     tg-task-status-display(ng-model="task")
    #
    # Requirements:
    #   - Task object (ng-model)
    #   - scope.statusById object

    template = $template.get("common/components/status-display.html", true)

    link = ($scope, $el, $attrs) ->
        render = (task) ->
            status =  $scope.statusById[task.status]

            html = template({
                is_closed: status.is_closed
                status: status
            })

            html = $compile(html)($scope)
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

module.directive("tgTaskStatusDisplay", ["$tgTemplate", "$compile", TaskStatusDisplayDirective])


#############################################################################
## Task status button directive
#############################################################################

TaskStatusButtonDirective = ($rootScope, $repo, $confirm, $loading, $modelTransform, $compile, $translate, $template) ->
    # Display the status of Task and you can edit it.
    #
    # Example:
    #     tg-task-status-button(ng-model="task")
    #
    # Requirements:
    #   - Task object (ng-model)
    #   - scope.statusById object
    #   - $scope.project.my_permissions

    template = $template.get("common/components/status-button.html", true)

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_task") != -1

        render = (task) =>
            status = $scope.statusById[task.status]

            html = $compile(template({
                status: status
                statuses: $scope.statusList
                editable: isEditable()
            }))($scope)

            $el.html(html)

        save = (status) ->
            currentLoading = $loading()
                .target($el)
                .start()

            transform = $modelTransform.save (task) ->
                task.status = status

                return task

            onSuccess = ->
                $rootScope.$broadcast("object:updated")
                currentLoading.finish()

            onError = ->
                $confirm.notify("error")
                currentLoading.finish()

            transform.then(onSuccess, onError)

        $el.on "click", ".js-edit-status", (event) ->
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

            save(target.data("status-id"))

        $scope.$watch () ->
            return $model.$modelValue?.status
        , () ->
            task = $model.$modelValue
            render(task) if task

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgTaskStatusButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQueueModelTransformation",
                                        "$compile", "$translate", "$tgTemplate", TaskStatusButtonDirective])


TaskIsIocaineButtonDirective = ($rootscope, $tgrepo, $confirm, $loading, $modelTransform, $compile, $template) ->
    template = $template.get("issue/iocaine-button.html", true)

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_task") != -1

        render = (task) ->
            if not isEditable() and not task.is_iocaine
                $el.html("")
                return

            ctx = {
                isIocaine: task.is_iocaine
                isEditable: isEditable()
            }
            html = $compile(template(ctx))($scope)
            $el.html(html)

        save = (is_iocaine) ->
            currentLoading = $loading()
                .target($el.find('label'))
                .start()

            transform = $modelTransform.save (task) ->
                task.is_iocaine = is_iocaine

                return task

            transform.then ->
                $rootscope.$broadcast("object:updated")

            transform.then null, ->
                $confirm.notify("error")

            transform.finally ->
                currentLoading.finish()

        $el.on "click", ".is-iocaine", (event) ->
            return if not isEditable()

            is_iocaine = not $model.$modelValue.is_iocaine
            save(is_iocaine)

        $scope.$watch () ->
            return $model.$modelValue?.is_iocaine
        , () ->
            task = $model.$modelValue
            render(task) if task

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgTaskIsIocaineButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQueueModelTransformation",
                                           "$compile", "$tgTemplate", TaskIsIocaineButtonDirective])
