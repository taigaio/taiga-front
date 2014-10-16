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
# File: modules/issues/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toString = @.taiga.toString
joinStr = @.taiga.joinStr
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce

module = angular.module("taigaIssues")

#############################################################################
## Issue Detail Controller
#############################################################################

class IssueDetailController extends mixOf(taiga.Controller, taiga.PageMixin)
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
        "$tgAnalytics",
        "$tgNavUrls"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @log, @appTitle, @analytics, @navUrls) ->
        @scope.issueRef = @params.issueref
        @scope.sectionName = "Issue Details"
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set(@scope.issue.subject + " - " + @scope.project.name)

        # On Error
        promise.then null, @.onInitialDataError.bind(@)


    initializeEventHandlers: ->
        @scope.$on "attachment:create", =>
            @rootscope.$broadcast("history:reload")
            @analytics.trackEvent("attachment", "create", "create attachment on issue", 1)

        @scope.$on "attachment:edit", =>
            @rootscope.$broadcast("history:reload")

        @scope.$on "attachment:delete", =>
            @rootscope.$broadcast("history:reload")

        @scope.$on "promote-issue-to-us:success", =>
            @analytics.trackEvent("issue", "promoteToUserstory", "promote issue to userstory", 1)
            @rootscope.$broadcast("history:reload")
            @.loadIssue()

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.statusList = project.issue_statuses
            @scope.statusById = groupBy(project.issue_statuses, (x) -> x.id)
            @scope.typeById = groupBy(project.issue_types, (x) -> x.id)
            @scope.typeList = _.sortBy(project.issue_types, "order")
            @scope.severityList = project.severities
            @scope.severityById = groupBy(project.severities, (x) -> x.id)
            @scope.priorityList = project.priorities
            @scope.priorityById = groupBy(project.priorities, (x) -> x.id)
            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            return project

    loadIssue: ->
        return @rs.issues.get(@scope.projectId, @scope.issueId).then (issue) =>
            @scope.issue = issue
            @scope.commentModel = issue

            if @scope.issue.neighbors.previous.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.issue.neighbors.previous.ref
                }
                @scope.previousUrl = @navUrls.resolve("project-issues-detail", ctx)

            if @scope.issue.neighbors.next.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.issue.neighbors.next.ref
                }
                @scope.nextUrl = @navUrls.resolve("project-issues-detail", ctx)

    loadInitialData: ->
        params = {
            pslug: @params.pslug
            issueref: @params.issueref
        }

        promise = @repo.resolve(params).then (data) =>
            @scope.projectId = data.project
            @scope.issueId = data.issue
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadIssue())

module.controller("IssueDetailController", IssueDetailController)


#############################################################################
## Issue status display directive
#############################################################################

IssueStatusDisplayDirective = ->
    # Display if a Issue is open or closed and its issueboard status.
    #
    # Example:
    #     tg-issue-status-display(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
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
        render = (issue) ->
            html = template({
                status: $scope.statusById[issue.status]
            })
            $el.html(html)

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue?

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueStatusDisplay", IssueStatusDisplayDirective)


#############################################################################
## Issue status button directive
#############################################################################

IssueStatusButtonDirective = ($rootScope, $repo, $confirm) ->
    # Display the status of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-status-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
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
            return $scope.project.my_permissions.indexOf("modify_issue") != -1

        render = (issue) =>
            status = $scope.statusById[issue.status]

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

            issue = $model.$modelValue.clone()
            issue.status = target.data("status-id")
            $model.$setViewValue(issue)

            onSuccess = ->
                $confirm.notify("success")
                $rootScope.$broadcast("history:reload")
            onError = ->
                $confirm.notify("error")
                issue.revert()
                $model.$setViewValue(issue)
            $repo.save($model.$modelValue).then(onSuccess, onError)

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueStatusButton", ["$rootScope", "$tgRepo", "$tgConfirm", IssueStatusButtonDirective])

#############################################################################
## Issue type button directive
#############################################################################

IssueTypeButtonDirective = ($rootScope, $repo, $confirm) ->
    # Display the type of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-type-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.typeById object
    #   - $scope.project.my_permissions

    template = _.template("""
    <div class="type-data <% if(editable){ %>clickable<% }%>">
        <span class="level" style="background-color:<%= type.color %>"></span>
        <span class="type-type"><%= type.name %></span>
        <% if(editable){ %><span class="icon icon-arrow-bottom"></span><% }%>
        <span class="level-name">type</span>

        <ul class="popover pop-type">
            <% _.each(typees, function(tp) { %>
            <li><a href="" class="type" title="<%- tp.name %>"
                   data-type-id="<%- tp.id %>"><%- tp.name %></a></li>
            <% }); %>
        </ul>
    </div>
    """) #TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_issue") != -1

        render = (issue) =>
            type = $scope.typeById[issue.type]

            html = template({
                type: type
                typees: $scope.typeList
                editable: isEditable()
            })
            $el.html(html)

        $el.on "click", ".type-data", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            $el.find(".pop-type").popover().open()

        $el.on "click", ".type", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            target = angular.element(event.currentTarget)

            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.type = target.data("type-id")
            $model.$setViewValue(issue)

            onSuccess = ->
                $confirm.notify("success")
                $rootScope.$broadcast("history:reload")
            onError = ->
                $confirm.notify("error")
                issue.revert()
                $model.$setViewValue(issue)
            $repo.save($model.$modelValue).then(onSuccess, onError)

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueTypeButton", ["$rootScope", "$tgRepo", "$tgConfirm", IssueTypeButtonDirective])


#############################################################################
## Issue severity button directive
#############################################################################

IssueSeverityButtonDirective = ($rootScope, $repo, $confirm) ->
    # Display the severity of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-severity-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.severityById object
    #   - $scope.project.my_permissions

    template = _.template("""
    <div class="severity-data <% if(editable){ %>clickable<% }%>">
        <span class="level" style="background-color:<%= severity.color %>"></span>
        <span class="severity-severity"><%= severity.name %></span>
        <% if(editable){ %><span class="icon icon-arrow-bottom"></span><% }%>
        <span class="level-name">severity</span>

        <ul class="popover pop-severity">
            <% _.each(severityes, function(sv) { %>
            <li><a href="" class="severity" title="<%- sv.name %>"
                   data-severity-id="<%- sv.id %>"><%- sv.name %></a></li>
            <% }); %>
        </ul>
    </div>
    """) #TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_issue") != -1

        render = (issue) =>
            severity = $scope.severityById[issue.severity]

            html = template({
                severity: severity
                severityes: $scope.severityList
                editable: isEditable()
            })
            $el.html(html)

        $el.on "click", ".severity-data", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            $el.find(".pop-severity").popover().open()

        $el.on "click", ".severity", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            target = angular.element(event.currentTarget)

            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.severity = target.data("severity-id")
            $model.$setViewValue(issue)

            onSuccess = ->
                $confirm.notify("success")
                $rootScope.$broadcast("history:reload")
            onError = ->
                $confirm.notify("error")
                issue.revert()
                $model.$setViewValue(issue)
            $repo.save($model.$modelValue).then(onSuccess, onError)

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueSeverityButton", ["$rootScope", "$tgRepo", "$tgConfirm", IssueSeverityButtonDirective])


#############################################################################
## Issue priority button directive
#############################################################################

IssuePriorityButtonDirective = ($rootScope, $repo, $confirm) ->
    # Display the priority of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-priority-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.priorityById object
    #   - $scope.project.my_permissions

    template = _.template("""
    <div class="priority-data <% if(editable){ %>clickable<% }%>">
        <span class="level" style="background-color:<%= priority.color %>"></span>
        <span class="priority-priority"><%= priority.name %></span>
        <% if(editable){ %><span class="icon icon-arrow-bottom"></span><% }%>
        <span class="level-name">priority</span>

        <ul class="popover pop-priority">
            <% _.each(priorityes, function(pr) { %>
            <li><a href="" class="priority" title="<%- pr.name %>"
                   data-priority-id="<%- pr.id %>"><%- pr.name %></a></li>
            <% }); %>
        </ul>
    </div>
    """) #TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_issue") != -1

        render = (issue) =>
            priority = $scope.priorityById[issue.priority]

            html = template({
                priority: priority
                priorityes: $scope.priorityList
                editable: isEditable()
            })
            $el.html(html)

        $el.on "click", ".priority-data", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            $el.find(".pop-priority").popover().open()

        $el.on "click", ".priority", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            target = angular.element(event.currentTarget)

            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.priority = target.data("priority-id")
            $model.$setViewValue(issue)

            onSuccess = ->
                $confirm.notify("success")
                $rootScope.$broadcast("history:reload")
            onError = ->
                $confirm.notify("error")
                issue.revert()
                $model.$setViewValue(issue)
            $repo.save($model.$modelValue).then(onSuccess, onError)

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssuePriorityButton", ["$rootScope", "$tgRepo", "$tgConfirm", IssuePriorityButtonDirective])


#############################################################################
## Promote Issue to US button directive
#############################################################################

PromoteIssueToUsButtonDirective = ($rootScope, $repo, $confirm) ->
    template = _.template("""
        <a class="button button-gray clickable" tg-check-permission="add_us">
            Promote to User Story
        </a>
    """)  # TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        $el.on "click", "a", (event) ->
            event.preventDefault()
            issue = $model.$modelValue

            title = "Promote this issue to a new user story" # TODO: i18n
            message = "Are you sure you want to create a new US from this Issue?" # TODO: i18n
            subtitle = issue.subject

            $confirm.ask(title, subtitle, message).then (finish) =>
                data = {
                    generated_from_issue: issue.id
                    project: issue.project,
                    subject: issue.subject
                    description: issue.description
                    tags: issue.tags
                    is_blocked: issue.is_blocked
                    blocked_note: issue.blocked_note
                }

                onSuccess = ->
                    finish()
                    $confirm.notify("success")
                    $rootScope.$broadcast("promote-issue-to-us:success")

                onError = ->
                    finish(false)
                    $confirm.notify("error")

                $repo.create("userstories", data).then(onSuccess, onError)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        restrict: "AE"
        require: "ngModel"
        template: template
        link: link
    }

module.directive("tgPromoteIssueToUsButton", ["$rootScope", "$tgRepo", "$tgConfirm",
                                              PromoteIssueToUsButtonDirective])
