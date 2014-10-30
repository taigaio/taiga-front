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
# File: modules/userstories/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce

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
        "$appTitle",
        "$tgNavUrls",
        "$tgAnalytics",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @log, @appTitle, @navUrls, @analytics, tgLoader) ->
        @scope.issueRef = @params.issueref
        @scope.sectionName = "User Story Details"
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set(@scope.us.subject + " - " + @scope.project.name)
            @.initializeOnDeleteGoToUrl()
            tgLoader.pageLoaded()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    initializeEventHandlers: ->
        @scope.$on "related-tasks:update", =>
            @.loadUs()
            @scope.tasks = _.clone(@scope.tasks, false)

        @scope.$on "attachment:create", =>
            @analytics.trackEvent("attachment", "create", "create attachment on userstory", 1)
            @rootscope.$broadcast("history:reload")

        @scope.$on "attachment:edit", =>
            @rootscope.$broadcast("history:reload")

        @scope.$on "attachment:delete", =>
            @rootscope.$broadcast("history:reload")

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
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.statusList = project.us_statuses
            @scope.statusById = groupBy(project.us_statuses, (x) -> x.id)
            @scope.taskStatusById = groupBy(project.task_statuses, (x) -> x.id)
            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            @scope.pointsList = _.sortBy(project.points, "order")
            @scope.pointsById = groupBy(@scope.pointsList, (e) -> e.id)
            return project

    loadUs: ->
        return @rs.userstories.get(@scope.projectId, @scope.usId).then (us) =>
            @scope.us = us
            @scope.commentModel = us

            if @scope.us.neighbors.previous.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.us.neighbors.previous.ref
                }
                @scope.previousUrl = @navUrls.resolve("project-userstories-detail", ctx)

            if @scope.us.neighbors.next.ref?
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
        params = {
            pslug: @params.pslug
            usref: @params.usref
        }

        promise = @repo.resolve(params).then (data) =>
            @scope.projectId = data.project
            @scope.usId = data.us
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @q.all([@.loadUs().then(=> @.loadSprint()),
                                       @.loadTasks()]))

module.controller("UserStoryDetailController", UserStoryDetailController)


#############################################################################
## User story status display directive
#############################################################################

UsStatusDisplayDirective = ->
    # Display if a US is open or closed and its kanban status.
    #
    # Example:
    #     tg-us-status-display(ng-model="us")
    #
    # Requirements:
    #   - US object (ng-model)
    #   - scope.statusById object

    template = _.template("""
    <span>
        <% if (is_closed) { %>
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
        render = (us) ->
            html = template({
                is_closed: us.is_closed
                status: $scope.statusById[us.status]
            })
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

module.directive("tgUsStatusDisplay", UsStatusDisplayDirective)


#############################################################################
## User story related tasts progress splay Directive
#############################################################################

UsTasksProgressDisplayDirective = ->
    # Display a progress bar with the stats of completed tasks.
    #
    # Example:
    #     tg-us-tasks-progress-display(ng-model="tasks")
    #
    # Requirements:
    #   - Task object list (ng-model)
    #   - scope.taskStatusById object

    template = _.template("""
    <div class="current-progress" style="width:<%- progress %>%" />
    <span clasS="tasks-completed">
        <%- totalClosedTasks %>/<%- totalTasks %> tasks completed
    </span>
    """) # TODO: i18n

    link = ($scope, $el, $attrs) ->
        render = (tasks) ->
            totalTasks = tasks.length
            totalClosedTasks = _.filter(tasks, (task) => $scope.taskStatusById[task.status].is_closed).length

            progress = if totalTasks > 0 then 100 * totalClosedTasks / totalTasks else 0

            html = template({
                totalTasks: totalTasks
                totalClosedTasks: totalClosedTasks
                progress: progress
            })
            $el.html(html)

        $scope.$watch $attrs.ngModel, (tasks) ->
            render(tasks) if tasks?

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsTasksProgressDisplay", UsTasksProgressDisplayDirective)


#############################################################################
## User story estimation directive
#############################################################################

UsEstimationDirective = ($rootScope, $repo, $confirm) ->
    # Display the points of a US and you can edit it.
    #
    # Example:
    #     tg-us-estimation-progress-bar(ng-model="us")
    #
    # Requirements:
    #   - Us object (ng-model)
    #   - scope.project object
    # Optionals:
    #   - save-after-modify (boolean): save object after modify

    mainTemplate = _.template("""
    <ul class="points-per-role">
        <li class="total">
            <span class="points"><%- totalPoints %></span>
            <span class="role">total</span>
        </li>
        <% _.each(roles, function(role) { %>
        <li class="total <% if(editable){ %>clickable<% } %>" data-role-id="<%- role.id %>">
            <span class="points"><%- role.points %></span>
            <span class="role"><%- role.name %></span></li>
        <% }); %>
    </ul>
    """)

    pointsTemplate = _.template("""
    <ul class="popover pop-points-open">
        <% _.each(points, function(point) { %>
        <li>
            <% if (point.selected) { %>
            <a href="" class="point" title="<%- point.name %>"
               data-point-id="<%- point.id %>" data-role-id="<%- roleId %>"><%- point.name %></a>
            <% } else { %>
            <a href="" class="point active" title="<%- point.name %>"
               data-point-id="<%- point.id %>" data-role-id="<%- roleId %>"><%- point.name %></a>
            <% } %>
        </li>
        <% }); %>
    </ul>
    """)

    link = ($scope, $el, $attrs, $model) ->
        saveAfterModify = $attrs.saveAfterModify or false

        isEditable = ->
            if $model.$modelValue.id
                return $scope.project.my_permissions.indexOf("modify_us") != -1
            return $scope.project.my_permissions.indexOf("add_us") != -1

        render = (us) ->
            totalPoints = us.total_points or 0
            computableRoles = _.filter($scope.project.roles, "computable")

            roles = _.map computableRoles, (role) ->
                pointId = us.points[role.id]
                pointObj = $scope.pointsById[pointId]

                role = _.clone(role, true)
                role.points = if pointObj? and pointObj.name? then pointObj.name else "?"
                return role

            ctx = {
                totalPoints: totalPoints
                roles: roles
                editable: isEditable()
            }
            html = mainTemplate(ctx)
            $el.html(html)

        renderPoints = (target, us, roleId) ->
            points = _.map $scope.project.points, (point) ->
                point = _.clone(point, true)
                point.selected = if us.points[roleId] == point.id then false else true
                return point

            html = pointsTemplate({"points": points, roleId: roleId})

            # Remove any prevous state
            $el.find(".popover").popover().close()
            $el.find(".pop-points-open").remove()

            # If not showing role selection let's move to the left
            if not $el.find(".pop-role:visible").css("left")?
                $el.find(".pop-points-open").css("left", "110px")

            $el.find(".pop-points-open").remove()

            # Render into DOM and show the new created element
            $el.find(target).append(html)

            $el.find(".pop-points-open").popover().open(-> $(this).removeClass("active"))
            $el.find(".pop-points-open").show()

        calculateTotalPoints = (us) ->
            values = _.map(us.points, (v, k) -> $scope.pointsById[v]?.value or 0)
            if values.length == 0
                return "0"
            return _.reduce(values, (acc, num) -> acc + num)

        $el.on "click", ".total.clickable", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            target = angular.element(event.currentTarget)
            roleId = target.data("role-id")

            us = $model.$modelValue
            renderPoints(target, us, roleId)

            target.siblings().removeClass('active')
            target.addClass('active')

        $el.on "click", ".point", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            target = angular.element(event.currentTarget)
            roleId = target.data("role-id")
            pointId = target.data("point-id")

            $el.find(".popover").popover().close()

            # NOTE: This block of code is strange and, sometimes, repetitive
            #       but is the only solution I find to update the object
            #       corectly
            us = angular.copy($model.$modelValue)
            points = _.clone($model.$modelValue.points, true)
            points[roleId] = pointId
            us.setAttr('points', points) if us.setAttr?
            us.points = points
            us.total_points = calculateTotalPoints(us)
            $model.$setViewValue(us)

            if saveAfterModify
                # Edit in the detail page
                onSuccess = ->
                    $confirm.notify("success")
                    $rootScope.$broadcast("history:reload")
                onError = ->
                    us.revert()
                    $model.$setViewValue(us)
                    $confirm.notify("error")
                $repo.save($model.$modelValue).then(onSuccess, onError)
            else
                # Create or eedit in the lightbox
                render($model.$modelValue)

        $scope.$watch $attrs.ngModel, (us) ->
            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsEstimation", ["$rootScope", "$tgRepo", "$tgConfirm", UsEstimationDirective])


#############################################################################
## User story status button directive
#############################################################################

UsStatusButtonDirective = ($rootScope, $repo, $confirm, $loading) ->
    # Display the status of a US and you can edit it.
    #
    # Example:
    #     tg-us-status-button(ng-model="us")
    #
    # Requirements:
    #   - Us object (ng-model)
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
            return $scope.project.my_permissions.indexOf("modify_us") != -1

        render = (us) =>
            status = $scope.statusById[us.status]

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

            us = $model.$modelValue.clone()
            us.status = target.data("status-id")
            $model.$setViewValue(us)

            $scope.$apply()

            onSuccess = ->
                $confirm.notify("success")
                $rootScope.$broadcast("history:reload")
                $loading.finish($el.find(".level-name"))

            onError = ->
                $confirm.notify("error")
                us.revert()
                $model.$setViewValue(us)
                $loading.finish($el.find(".level-name"))

            $loading.start($el.find(".level-name"))
            $repo.save($model.$modelValue).then(onSuccess, onError)

        $scope.$watch $attrs.ngModel, (us) ->
            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsStatusButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading",
                                      UsStatusButtonDirective])


#############################################################################
## User story team requirements button directive
#############################################################################

UsTeamRequirementButtonDirective = ($rootscope, $tgrepo, $confirm, $loading) ->
    template = _.template("""
    <label for="team-requirement"
           class="button button-gray team-requirement <% if(canEdit){ %>editable<% }; %> <% if(isRequired){ %>active<% }; %>">
        Team requirement
    </label>
    <input type="checkbox" id="team-requirement" name="team-requirement"/>
    """) #TODO: i18n

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
            $el.html(html)

        $el.on "click", ".team-requirement", (event) ->
            return if not canEdit()

            us = $model.$modelValue.clone()
            us.team_requirement = not us.team_requirement
            $model.$setViewValue(us)

            $loading.start($el.find("label"))
            promise = $tgrepo.save($model.$modelValue)
            promise.then =>
                $loading.finish($el.find("label"))
                $rootscope.$broadcast("history:reload")
            promise.then null, ->
                $loading.finish($el.find("label"))
                $confirm.notify("error")
                us.revert()
                $model.$setViewValue(us)

        $scope.$watch $attrs.ngModel, (us) ->
            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsTeamRequirementButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", UsTeamRequirementButtonDirective])

#############################################################################
## User story client requirements button directive
#############################################################################

UsClientRequirementButtonDirective = ($rootscope, $tgrepo, $confirm, $loading) ->
    template = _.template("""
    <label for="client-requirement"
           class="button button-gray client-requirement <% if(canEdit){ %>editable<% }; %> <% if(isRequired){ %>active<% }; %>">
        Client requirement
    </label>
    <input type="checkbox" id="client-requirement" name="client-requirement"/>
    """) #TODO: i18n

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
            html = template(ctx)
            $el.html(html)

        $el.on "click", ".client-requirement", (event) ->
            return if not canEdit()

            us = $model.$modelValue.clone()
            us.client_requirement = not us.client_requirement
            $model.$setViewValue(us)

            $loading.start($el.find("label"))
            promise = $tgrepo.save($model.$modelValue)
            promise.then =>
                $loading.finish($el.find("label"))
                $rootscope.$broadcast("history:reload")
            promise.then null, ->
                $loading.finish($el.find("label"))
                $confirm.notify("error")
                us.revert()
                $model.$setViewValue(us)

        $scope.$watch $attrs.ngModel, (us) ->
            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsClientRequirementButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading",
                                                 UsClientRequirementButtonDirective])
