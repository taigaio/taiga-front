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
# File: modules/userstories/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
bindMethods = @.taiga.bindMethods

module = angular.module("taigaUserStories")

#############################################################################
## User story Detail Controller
#############################################################################

class UserStoryDetailController extends mixOf(taiga.Controller, taiga.PageMixin)
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
        "$translate"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @log, @appMetaService, @navUrls, @analytics, @translate) ->
        bindMethods(@)

        @scope.usRef = @params.usref
        @scope.sectionName = @translate.instant("US.SECTION_NAME")
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @._setMeta()
            @.initializeOnDeleteGoToUrl()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    _setMeta: ->
        totalTasks = @scope.tasks.length
        closedTasks = _.filter(@scope.tasks, (t) => @scope.taskStatusById[t.status].is_closed).length
        progressPercentage = if totalTasks > 0 then Math.round(100 * closedTasks / totalTasks) else 0

        title = @translate.instant("US.PAGE_TITLE", {
            userStoryRef: "##{@scope.us.ref}"
            userStorySubject: @scope.us.subject
            projectName: @scope.project.name
        })
        description = @translate.instant("US.PAGE_DESCRIPTION", {
            userStoryStatus: @scope.statusById[@scope.us.status]?.name or "--"
            userStoryPoints: @scope.us.total_points
            userStoryDescription: angular.element(@scope.us.description_html or "").text()
            userStoryClosedTasks: closedTasks
            userStoryTotalTasks: totalTasks
            userStoryProgressPercentage: progressPercentage
        })

        @appMetaService.setAll(title, description)

    initializeEventHandlers: ->
        @scope.$on "related-tasks:update", =>
            @scope.tasks = _.clone(@scope.tasks, false)

        @scope.$on "attachment:create", =>
            @analytics.trackEvent("attachment", "create", "create attachment on userstory", 1)

        @scope.$on "comment:new", =>
            @.loadUs()

    initializeOnDeleteGoToUrl: ->
        ctx = {project: @scope.project.slug}
        @scope.onDeleteGoToUrl = @navUrls.resolve("project", ctx)
        if @scope.project.is_backlog_activated
            if @scope.us.milestone
                ctx.sprint = @scope.sprint.slug
                @scope.onDeleteGoToUrl = @navUrls.resolve("project-taskboard", ctx)
            else
                @scope.onDeleteGoToUrl = @navUrls.resolve("project-backlog", ctx)
        else if @scope.project.is_kanban_activated
            @scope.onDeleteGoToUrl = @navUrls.resolve("project-kanban", ctx)

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            @scope.projectId = project.id
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.statusList = project.us_statuses
            @scope.statusById = groupBy(project.us_statuses, (x) -> x.id)
            @scope.taskStatusById = groupBy(project.task_statuses, (x) -> x.id)
            @scope.pointsList = _.sortBy(project.points, "order")
            @scope.pointsById = groupBy(@scope.pointsList, (e) -> e.id)
            return project

    loadUs: ->
        httpParams = _.pick(@location.search(), "milestone", "no-milestone", "kanban-status")
        milestone = httpParams.milestone
        if milestone
            @rs.userstories.storeQueryParams(@scope.projectId, {
                milestone: milestone
                order_by: "sprint_order"
            })

        noMilestone = httpParams["no-milestone"]
        if noMilestone
            @rs.userstories.storeQueryParams(@scope.projectId, {
                milestone: "null"
                order_by: "backlog_order"
            })

        kanbanStaus = httpParams["kanban-status"]
        if kanbanStaus
            @rs.userstories.storeQueryParams(@scope.projectId, {
                status: kanbanStaus
                order_by: "kanban_order"
            })



        return @rs.userstories.getByRef(@scope.projectId, @params.usref).then (us) =>
            @scope.us = us
            @scope.usId = us.id
            @scope.commentModel = us

            if @scope.us.neighbors.previous?.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.us.neighbors.previous.ref
                }
                @scope.previousUrl = @navUrls.resolve("project-userstories-detail", ctx)

            if @scope.us.neighbors.next?.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.us.neighbors.next.ref
                }
                @scope.nextUrl = @navUrls.resolve("project-userstories-detail", ctx)

            return us

    loadSprint: ->
        if @scope.us.milestone
            return @rs.sprints.get(@scope.us.project, @scope.us.milestone).then (sprint) =>
                @scope.sprint = sprint
                return sprint

    loadTasks: ->
        return @rs.tasks.list(@scope.projectId, null, @scope.usId).then (tasks) =>
            @scope.tasks = tasks
            return tasks

    loadInitialData: ->
        promise = @.loadProject()
        return promise.then (project) =>
            @.fillUsersAndRoles(project.members, project.roles)
            @.loadUs().then(=> @q.all([@.loadSprint(), @.loadTasks()]))

    ###
    # Note: This methods (onUpvote() and onDownvote()) are related to tg-vote-button.
    #       See app/modules/components/vote-button for more info
    ###
    onUpvote: ->
        onSuccess = =>
            @.loadUs()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.userstories.upvote(@scope.usId).then(onSuccess, onError)

    onDownvote: ->
        onSuccess = =>
            @.loadUs()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.userstories.downvote(@scope.usId).then(onSuccess, onError)

    ###
    # Note: This methods (onWatch() and onUnwatch()) are related to tg-watch-button.
    #       See app/modules/components/watch-button for more info
    ###
    onWatch: ->
        onSuccess = =>
            @.loadUs()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.userstories.watch(@scope.usId).then(onSuccess, onError)

    onUnwatch: ->
        onSuccess = =>
            @.loadUs()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.userstories.unwatch(@scope.usId).then(onSuccess, onError)

module.controller("UserStoryDetailController", UserStoryDetailController)


#############################################################################
## User story status display directive
#############################################################################

UsStatusDisplayDirective = ($template, $compile) ->
    # Display if a US is open or closed and its kanban status.
    #
    # Example:
    #     tg-us-status-display(ng-model="us")
    #
    # Requirements:
    #   - US object (ng-model)
    #   - scope.statusById object

    template = $template.get("common/components/status-display.html", true)

    link = ($scope, $el, $attrs) ->
        render = (us) ->
            status = $scope.statusById[us.status]

            html = template({
                is_closed: us.is_closed
                status: status
            })

            html = $compile(html)($scope)
            $el.html(html)

        $scope.$watch $attrs.ngModel, (us) ->
            render(us) if us?

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsStatusDisplay", ["$tgTemplate", "$compile", UsStatusDisplayDirective])


#############################################################################
## User story related tasts progress splay Directive
#############################################################################

UsTasksProgressDisplayDirective = ($template, $compile) ->
    # Display a progress bar with the stats of completed tasks.
    #
    # Example:
    #     tg-us-tasks-progress-display(ng-model="tasks")
    #
    # Requirements:
    #   - Task object list (ng-model)
    #   - scope.taskStatusById object

    link = ($scope, $el, $attrs) ->
        render = (tasks) ->
            totalTasks = tasks.length
            totalClosedTasks = _.filter(tasks, (task) => $scope.taskStatusById[task.status].is_closed).length

            progress = if totalTasks > 0 then 100 * totalClosedTasks / totalTasks else 0

            _.assign($scope, {
                totalTasks: totalTasks
                totalClosedTasks: totalClosedTasks
                progress: progress,
                style: {
                    width: progress + "%"
                }
            })

        $scope.$watch $attrs.ngModel, (tasks) ->
            render(tasks) if tasks?

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "us/us-task-progress.html"
        link: link
        restrict: "EA"
        require: "ngModel"
        scope: true
    }

module.directive("tgUsTasksProgressDisplay", ["$tgTemplate", "$compile", UsTasksProgressDisplayDirective])


#############################################################################
## User story status button directive
#############################################################################

UsStatusButtonDirective = ($rootScope, $repo, $confirm, $loading, $qqueue, $template) ->
    # Display the status of a US and you can edit it.
    #
    # Example:
    #     tg-us-status-button(ng-model="us")
    #
    # Requirements:
    #   - Us object (ng-model)
    #   - scope.statusById object
    #   - $scope.project.my_permissions

    template = $template.get("us/us-status-button.html", true)

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_us") != -1

        render = (us) =>
            status = $scope.statusById[us.status]

            html = template({
                status: status
                statuses: $scope.statusList
                editable: isEditable()
            })

            $el.html(html)

        save = $qqueue.bindAdd (status) =>
            us = $model.$modelValue.clone()

            us.status = status

            $.fn.popover().closeAll()

            currentLoading = $loading()
                .target($el.find(".level-name"))
                .start()

            onSuccess = ->
                $confirm.notify("success")
                $model.$setViewValue(us)
                $rootScope.$broadcast("object:updated")
                currentLoading.finish()

            onError = ->
                $confirm.notify("error")
                currentLoading.finish()

            $repo.save(us).then(onSuccess, onError)

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
            status = target.data("status-id")

            save(status)

        $scope.$watch $attrs.ngModel, (us) ->
            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsStatusButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading","$tgQqueue", "$tgTemplate",
                                      UsStatusButtonDirective])


#############################################################################
## User story team requirements button directive
#############################################################################

UsTeamRequirementButtonDirective = ($rootscope, $tgrepo, $confirm, $loading, $qqueue, $template, $compile) ->
    template = $template.get("us/us-team-requirement-button.html", true)

    link = ($scope, $el, $attrs, $model) ->
        canEdit = ->
            return $scope.project.my_permissions.indexOf("modify_us") != -1

        render = (us) ->
            if not canEdit() and not us.team_requirement
                $el.html("")
                return

            ctx = {
                canEdit: canEdit()
                isRequired: us.team_requirement
            }
            html = template(ctx)
            html = $compile(html)($scope)

            $el.html(html)

        save = $qqueue.bindAdd (team_requirement) =>
            us = $model.$modelValue.clone()
            us.team_requirement = team_requirement

            currentLoading = $loading()
                .target($el.find("label"))
                .start()

            promise = $tgrepo.save(us)
            promise.then =>
                $model.$setViewValue(us)
                currentLoading.finish()
                $rootscope.$broadcast("object:updated")

            promise.then null, ->
                currentLoading.finish()
                $confirm.notify("error")

        $el.on "click", ".team-requirement", (event) ->
            return if not canEdit()

            team_requirement = not $model.$modelValue.team_requirement

            save(team_requirement)

        $scope.$watch $attrs.ngModel, (us) ->
            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsTeamRequirementButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQqueue", "$tgTemplate", "$compile", UsTeamRequirementButtonDirective])

#############################################################################
## User story client requirements button directive
#############################################################################

UsClientRequirementButtonDirective = ($rootscope, $tgrepo, $confirm, $loading, $qqueue, $template, $compile) ->
    template = $template.get("us/us-client-requirement-button.html", true)

    link = ($scope, $el, $attrs, $model) ->
        canEdit = ->
            return $scope.project.my_permissions.indexOf("modify_us") != -1

        render = (us) ->
            if not canEdit() and not us.client_requirement
                $el.html("")
                return

            ctx = {
                canEdit: canEdit()
                isRequired: us.client_requirement
            }
            html = $compile(template(ctx))($scope)
            $el.html(html)

        save = $qqueue.bindAdd (client_requirement) =>
            us = $model.$modelValue.clone()
            us.client_requirement = client_requirement

            currentLoading = $loading()
                .target($el.find("label"))
                .start()

            promise = $tgrepo.save(us)
            promise.then =>
                $model.$setViewValue(us)
                currentLoading.finish()
                $rootscope.$broadcast("object:updated")

            promise.then null, ->
                $confirm.notify("error")

        $el.on "click", ".client-requirement", (event) ->
            return if not canEdit()

            client_requirement = not $model.$modelValue.client_requirement
            save(client_requirement)

        $scope.$watch $attrs.ngModel, (us) ->
            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsClientRequirementButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQqueue", "$tgTemplate", "$compile",
                                                 UsClientRequirementButtonDirective])
