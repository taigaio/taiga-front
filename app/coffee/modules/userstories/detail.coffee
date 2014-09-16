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
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @log, @appTitle, @navUrls, tgLoader) ->
        @scope.issueRef = @params.issueref
        @scope.sectionName = "User Story Details"

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set(@scope.us.subject + " - " + @scope.project.name)
            tgLoader.pageLoaded()

        # On Error
        promise.then null, (xhr) =>
            if xhr and xhr.status == 404
                @location.path("/not-found")
                @location.replace()
            return @q.reject(xhr)

        @scope.$on("attachment:create", => @rootscope.$broadcast("history:reload"))
        @scope.$on("attachment:edit", => @rootscope.$broadcast("history:reload"))
        @scope.$on("attachment:delete", => @rootscope.$broadcast("history:reload"))

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
                      .then(=> @.loadUs())


    block: ->
        @rootscope.$broadcast("block", @scope.us)

    unblock: ->
        @rootscope.$broadcast("unblock", @scope.us)


    delete: ->
        #TODO: i18n
        title = "Delete User Story"
        subtitle = @scope.us.subject

        @confirm.ask(title, subtitle).then =>
            @.repo.remove(@scope.us).then =>
                @location.path(@navUrls.resolve("project-backlog", {project: @scope.project.slug}))

module.controller("UserStoryDetailController", UserStoryDetailController)



#############################################################################
## User story Main Directive
#############################################################################

UsDirective = ($tgrepo, $log, $location, $confirm, $navUrls, $loading) ->
    linkSidebar = ($scope, $el, $attrs, $ctrl) ->

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSidebar($scope, $el, $attrs, $ctrl)

        if $el.is("form")
            form = $el.checksley()

        $el.on "click", ".save-us", (event) ->
            if not form.validate()
                return

            onSuccess = ->
                $loading.finish(target)
                $confirm.notify("success")
                ctx = {
                    project: $scope.project.slug
                    ref: $scope.us.ref
                }
                $location.path($navUrls.resolve("project-userstories-detail", ctx))

            onError = ->
                $loading.finish(target)
                $confirm.notify("error")

            target = angular.element(event.currentTarget)
            $loading.start(target)
            $tgrepo.save($scope.us).then(onSuccess, onError)

    return {link:link}

module.directive("tgUsDetail", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", "$tgNavUrls", "$tgLoading", UsDirective])


#############################################################################
## User story status directive
#############################################################################

UsStatusDetailDirective = () ->
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

        <% if (showTasks) { %>
        <div class="us-detail-progress-bar">
            <div class="current-progress" style="width:<%- usProgress %>%"/>
            <span clasS="tasks-completed">
                <%- totalClosedTasks %>/<%- totalTasks %> tasks completed
            </span>
        </div>
        <% } %>

        <div class="us-created-by">
            <div class="user-avatar">
                <img src="<%= owner.photo %>" alt="<%- owner.full_name_display %>" />
            </div>

            <div class="created-by">
                <span class="created-title">Created by <%- owner.full_name_display %></span>
                <span class="created-date"><%- date %></span>
            </div>
        </div>

        <ul class="points-per-role">
            <li class="total">
                <span class="points"><%- totalPoints %></span>
                <span class="role">total</span>
            </li>
            <% _.each(rolePoints, function(rolePoint) { %>
            <li class="total <% if (editable) { %>clickable<% } %>" data-role-id="<%- rolePoint.id %>">
                <span class="points"><%- rolePoint.points %></span>
                <span class="role"><%- rolePoint.name %></span></li>
            <% }); %>
        </ul>

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
    selectionPointsTemplate = _.template("""
    <ul class="popover pop-points-open">
        <% _.each(points, function(point) { %>
        <li><a href="" class="point" title="<%- point.name %>"
               data-point-id="<%- point.id %>"><%- point.name %></a>
        </li>
        <% }); %>
    </ul>
    """)

    link = ($scope, $el, $attrs, $model) ->
        editable = $attrs.editable?
        updatingSelectedRoleId = null

        showSelectPoints = (onClose) ->
            us = $model.$modelValue
            $el.find(".pop-points-open").remove()
            $el.find(".points-per-role").append(selectionPointsTemplate({ "points":  $scope.project.points }))
            $el.find(".pop-points-open a[data-point-id='#{us.points[updatingSelectedRoleId]}']").addClass("active")
            # If not showing role selection let's move to the left
            $el.find(".pop-points-open").popover().open(onClose)

        calculateTotalPoints = (us)->
            values = _.map(us.points, (v, k) -> $scope.pointsById[v].value)
            values = _.filter(values, (num) -> num?)
            if values.length == 0
                return "?"

            return _.reduce(values, (acc, num) -> acc + num)

        renderUsstatus = (us) ->
            owner = $scope.usersById?[us.owner]
            date = moment(us.created_date).format("DD MMM YYYY HH:mm")
            status = $scope.statusById[us.status]
            rolePoints = _.clone(_.filter($scope.project.roles, "computable"), true)
            _.map rolePoints, (v, k) ->
                  val = $scope.pointsById[us.points[v.id]].value
                  val = "?" if not val?
                  v.points = val

            if $scope.tasks
                totalTasks = $scope.tasks.length
                totalClosedTasks = _.filter($scope.tasks, (task) => $scope.taskStatusById[task.status].is_closed).length
                showTasks = true
            else
                showTasks = false

            usProgress = 0
            usProgress = 100 * totalClosedTasks / totalTasks if totalTasks > 0
            html = template({
                owner: owner
                date: date
                editable: editable
                status: status
                totalPoints: us.total_points
                rolePoints: rolePoints
                totalTasks: totalTasks
                totalClosedTasks: totalClosedTasks
                totalTasks: totalTasks
                totalClosedTasks: totalClosedTasks
                showTasks: showTasks
                usProgress: usProgress
            })
            $el.html(html)
            $el.find(".status-data").append(selectionStatusTemplate({statuses:$scope.statusList}))

        $scope.$watch $attrs.ngModel, (us) ->
            if us?
                renderUsstatus(us)

        bindOnce $scope, "tasks", (tasks) ->
            $scope.$watch $attrs.ngModel, (us) ->
                if us?
                    renderUsstatus(us)

        $scope.$on "related-tasks:update", ->
            us = $scope.$eval $attrs.ngModel
            if us?
                renderUsstatus(us)

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
                renderUsstatus($model.$modelValue)
                $.fn.popover().closeAll()

            $el.on "click", ".total.clickable", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                updatingSelectedRoleId = target.data("role-id")
                target.siblings().removeClass('active')
                target.addClass('active')
                showSelectPoints(() -> target.removeClass('active'))
            $el.on "click", ".point", (event) ->
                event.preventDefault()
                event.stopPropagation()

                target = angular.element(event.currentTarget)
                $.fn.popover().closeAll()

                $scope.$apply () ->
                    us = $model.$modelValue
                    usPoints = _.clone(us.points, true)
                    usPoints[updatingSelectedRoleId] = target.data("point-id")
                    us.points = usPoints
                    us.total_points = calculateTotalPoints(us)
                    renderUsstatus(us)

    return {link:link, require:"ngModel"}

module.directive("tgUsStatusDetail", UsStatusDetailDirective)
