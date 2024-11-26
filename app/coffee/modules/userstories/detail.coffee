###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
        "$translate",
        "$tgQueueModelTransformation",
        "tgErrorHandlingService",
        "$tgConfig",
        "tgProjectService",
        "tgWysiwygService",
        "tgAttachmentsFullService",
        "$tgModel",
        "$sce"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @log, @appMetaService, @navUrls, @analytics, @translate, @modelTransform,
                  @errorHandlingService, @configService, @projectService, @wysiwigService,
                  @attachmentsFullService, @tgmodel, @sce) ->
        bindMethods(@)

        @scope.usRef = @params.usref
        @scope.sectionName = @translate.instant("US.SECTION_NAME")
        @scope.tribeEnabled = @configService.config.tribeHost
        @scope.attachmentsReady = false
        @scope.$on "attachments:loaded", () =>
            @scope.attachmentsReady = true

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

        descriptionHtml = @sce.getTrustedHtml(@wysiwigService.getHTML(@scope.us.description) or "")

        description = @translate.instant("US.PAGE_DESCRIPTION", {
            userStoryStatus: @scope.statusById[@scope.us.status]?.name or "--"
            userStoryPoints: @scope.us.total_points
            userStoryDescription: angular.element(descriptionHtml).text()
            userStoryClosedTasks: closedTasks
            userStoryTotalTasks: totalTasks
            userStoryProgressPercentage: progressPercentage
        })

        @appMetaService.setAll(title, description)

    loadAttachments: ->
        @attachmentsFullService.loadAttachments('us', @scope.usId, @scope.projectId)

    initializeEventHandlers: ->
        @scope.relateToEpic = (us) =>
            @scope.$broadcast("relate-to-epic:add", us)

        @scope.$on "related-tasks:update", =>
            @.loadTasks()
            @scope.tasks = _.clone(@scope.tasks, false)
            allClosed = _.every @scope.tasks, (task) -> return task.is_closed

            if @scope.us.is_closed != allClosed
                @.loadUs()

        @scope.$on "attachment:create", =>
            @analytics.trackEvent("attachment", "create", "create attachment on userstory", 1)

        @scope.$on "task:reorder", (event, task, newIndex) =>
            @.reorderTask(task, newIndex)

        @scope.$on "comment:new", =>
            @.loadUs()

    initializeOnDeleteGoToUrl: ->
        ctx = {project: @scope.project.slug}
        @scope.onDeleteGoToUrl = @navUrls.resolve("project", ctx)

        if @params["kanban-status"] && @scope.project.is_kanban_activated
            @scope.onDeleteGoToUrl = @navUrls.resolve("project-kanban", ctx)

        else
            if @scope.project.is_backlog_activated
                if @scope.us.milestone
                    ctx.sprint = @scope.sprint.slug
                    @scope.onDeleteGoToUrl = @navUrls.resolve("project-taskboard", ctx)
                else
                    @scope.onDeleteGoToUrl = @navUrls.resolve("project-backlog", ctx)


    loadProject: ->
        project = @projectService.project.toJS()

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
        kanbanHttpParams = {}
        locationSearch = @location.search()
        backlogHttpParams = _.pick(locationSearch, "milestone", "no-milestone")

        Object.keys(locationSearch).forEach (key) ->
            if key.startsWith('kanban-')
                kanbanHttpParams[key.replace('kanban-', '')] = locationSearch[key]

        Object.keys(locationSearch).forEach (key) ->
            if key.startsWith('backlog-')
                backlogHttpParams[key.replace('backlog-', '')] = locationSearch[key]

        milestone = backlogHttpParams.milestone

        if milestone
            @rs.userstories.storeQueryParams(@scope.projectId,  _.merge(
                backlogHttpParams,
                {
                    milestone: milestone
                    order_by: "sprint_order"
                }
            ))

        noMilestone = backlogHttpParams["no-milestone"]
        if noMilestone
            @rs.userstories.storeQueryParams(@scope.projectId, _.merge(
                backlogHttpParams,
                {
                    milestone: "null"
                    order_by: "backlog_order"
                }
            ))

        kanbanStaus = kanbanHttpParams["status"]
        if kanbanStaus
            @rs.userstories.storeQueryParams(@scope.projectId, _.merge(
                kanbanHttpParams,
                {order_by: "kanban_order"}
            ))

        return @rs.userstories.getByRef(@scope.projectId, @params.usref).then (us) =>
            @rootscope.$broadcast("userstory:loaded", us)

            @scope.us = us
            @scope.usId = us.id
            @scope.commentModel = us

            @.loadAttachments()

            window.legacyChannel.next({
                type: 'SET_DETAIL_OBJ',
                value: us._attrs
            })

            @modelTransform.setObject(@scope, 'us')

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
        project = @.loadProject()
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

    onTribeInfo: ->
        publishTitle = @translate.instant("US.TRIBE.PUBLISH_MORE_INFO_TITLE")
        image = $('<img />')
            .attr({
                'src': "/#{window._version}/images/monster-fight.png",
                'alt': @translate.instant("US.TRIBE.PUBLISH_MORE_INFO_TITLE")
            })
        text = @translate.instant("US.TRIBE.PUBLISH_MORE_INFO_TEXT")
        publishDesc = $('<div></div>').append(image).append(text)
        @confirm.success(publishTitle, publishDesc)

    reorderTask: (task, newIndex) ->
        orderList = {}
        @scope.tasks.forEach (it) ->
            orderList[it.id] = it.us_order

        withoutMoved = @scope.tasks.filter (it) -> it.id != task.id
        beforeDestination = withoutMoved.slice(0, newIndex)
        afterDestination = withoutMoved.slice(newIndex)

        previous = beforeDestination[beforeDestination.length - 1]
        newOrder = if !previous then 0 else previous.us_order + 1

        orderList[task.id] = newOrder

        previousWithTheSameOrder = beforeDestination.filter (it) ->
            it.us_order == previous.us_order

        setOrders = _.fromPairs previousWithTheSameOrder.map((it) ->
            [it.id, it.us_order]
        )

        afterDestination.forEach (it) -> orderList[it.id] = it.us_order + 1

        @scope.tasks =  _.map(@scope.tasks, (it) ->
            it.us_order = orderList[it.id]
            return it
        )
        @scope.tasks = _.sortBy(@scope.tasks, "us_order")

        data = {
            us_order: newOrder,
            version: task.version
        }

        return @rs.tasks.reorder(task.id, data, setOrders).then (newTask) =>
            newTask = @tgmodel.make_model("tasks", newTask)

            @scope.tasks =  _.map(@scope.tasks, (it) ->
                return if it.id == newTask.id then newTask else it
            )
            @rootscope.$broadcast("related-tasks:reordered")



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
## User story status button directive
#############################################################################

UsStatusButtonDirective = ($rootScope, $repo, $confirm, $loading, $modelTransform, $template, $compile) ->
    # Display the status of a US and you can edit it.
    #
    # Example:
    #     tg-us-status-button(ng-model="us")
    #
    # Requirements:
    #   - Us object (ng-model)
    #   - scope.statusById object
    #   - $scope.project.my_permissions

    template = $template.get("common/components/status-button.html", true)

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

            $compile($el.contents())($scope)

        save = (status) =>
            $el.find(".pop-status").popover().close()

            currentLoading = $loading()
                .target($el.find('.js-edit-status'))
                .start()

            transform = $modelTransform.save (us) ->
                us.status = status

                return us

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
            status = target.data("status-id")

            save(status)

        $scope.$watch () ->
            return $model.$modelValue?.status
        , () ->
            us = $model.$modelValue

            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsStatusButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading","$tgQueueModelTransformation", "$tgTemplate", "$compile",
                                      UsStatusButtonDirective])


#############################################################################
## User story team requirements button directive
#############################################################################

UsTeamRequirementButtonDirective = ($rootscope, $tgrepo, $confirm, $loading, $modelTransform, $template, $compile) ->
    template = $template.get("us/us-team-requirement-button.html", true)

    link = ($scope, $el, $attrs, $model) ->
        canEdit = ->
            return $scope.project.my_permissions.indexOf("modify_us") != -1

        render = (us) ->
            ctx = {
                canEdit: canEdit()
                isRequired: us.team_requirement
            }
            html = template(ctx)
            html = $compile(html)($scope)

            $el.html(html)

        save = (team_requirement) ->
            currentLoading = $loading()
                .target($el.find("label"))
                .start()

            transform = $modelTransform.save (us) ->
                us.team_requirement = team_requirement

                return us

            transform.then =>
                currentLoading.finish()
                $rootscope.$broadcast("object:updated")

            transform.then null, ->
                currentLoading.finish()
                $confirm.notify("error")

        $el.on "click", ".team-requirement", (event) ->
            return if not canEdit()

            team_requirement = not $model.$modelValue.team_requirement

            save(team_requirement)

        $scope.$watch () ->
            return $model.$modelValue?.team_requirement
        , () ->
            us = $model.$modelValue

            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsTeamRequirementButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$compile", UsTeamRequirementButtonDirective])

#############################################################################
## User story client requirements button directive
#############################################################################

UsClientRequirementButtonDirective = ($rootscope, $tgrepo, $confirm, $loading, $modelTransform, $template, $compile) ->
    template = $template.get("us/us-client-requirement-button.html", true)

    link = ($scope, $el, $attrs, $model) ->
        canEdit = ->
            return $scope.project.my_permissions.indexOf("modify_us") != -1

        render = (us) ->
            ctx = {
                canEdit: canEdit()
                isRequired: us.client_requirement
            }
            html = $compile(template(ctx))($scope)
            $el.html(html)

        save = (client_requirement) ->
            currentLoading = $loading()
                .target($el.find("label"))
                .start()

            transform = $modelTransform.save (us) ->
                us.client_requirement = client_requirement

                return us

            transform.then =>
                currentLoading.finish()
                $rootscope.$broadcast("object:updated")

            transform.then null, ->
                $confirm.notify("error")

        $el.on "click", ".client-requirement", (event) ->
            return if not canEdit()

            client_requirement = not $model.$modelValue.client_requirement
            save(client_requirement)

        $scope.$watch () ->
            return $model.$modelValue?.client_requirement
        , () ->
            us = $model.$modelValue
            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsClientRequirementButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$compile",
                                                 UsClientRequirementButtonDirective])
