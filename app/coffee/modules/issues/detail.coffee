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
## Issue Main Directive
#############################################################################

IssueDirective = ($tgrepo, $log, $location, $confirm, $navUrls, $loading) ->
    linkSidebar = ($scope, $el, $attrs, $ctrl) ->

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSidebar($scope, $el, $attrs, $ctrl)

        if $el.is("form")
            form = $el.checksley()

        $el.on "click", ".save-issue", (event) ->
            if not form.validate()
                return

            onSuccess = ->
                $loading.finish(target)
                $confirm.notify("success")
                ctx = {
                    project: $scope.project.slug
                    ref: $scope.issue.ref
                }
                $location.path($navUrls.resolve("project-issues-detail", ctx))

            onError = ->
                $loading.finish(target)
                $confirm.notify("error")

            target = angular.element(event.currentTarget)
            $loading.start(target)
            $tgrepo.save($scope.issue).then(onSuccess, onError)

    return {link:link}

module.directive("tgIssueDetail", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", "$tgNavUrls",
                                   "$tgLoading", IssueDirective])


#############################################################################
## Issue status directive
#############################################################################

IssueStatusDirective = () ->
    # TODO: i18n
    template = _.template("""
    <h1>
        <span>
        <% if (status.is_closed) { %>
        Closed
        <% } else { %>
        Open
        <% } %>
        </span>
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
        <div class="type-data <% if (editable) { %>clickable<% } %>">
            <span class="level" style="background-color:<%= type.color %>"></span>
            <span class="type-status"><%= type.name %></span>
            <% if (editable) { %>
                <span class="icon icon-arrow-bottom"></span>
            <% } %>
            <span class="level-name">type</span>
        </div>
        <div class="severity-data <% if (editable) { %>clickable<% } %>">
            <span class="level" style="background-color:<%= severity.color %>"></span>
            <span class="severity-status"><%= severity.name %></span>
            <% if (editable) { %>
                <span class="icon icon-arrow-bottom"></span>
            <% } %>
            <span class="level-name">severity</span>
        </div>
        <div class="priority-data <% if (editable) { %>clickable<% } %>">
            <span class="level" style="background-color:<%= priority.color %>"></span>
            <span class="priority-status"><%= priority.name %></span>
            <% if (editable) { %>
                <span class="icon icon-arrow-bottom"></span>
            <% } %>
            <span class="level-name">priority</span>
        </div>
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
    selectionTypeTemplate = _.template("""
    <ul class="popover pop-type">
        <% _.each(types, function(type) { %>
        <li><a href="" class="type" title="<%- type.name %>"
               data-type-id="<%- type.id %>"><%- type.name %></a></li>
        <% }); %>
    </ul>
    """)
    selectionSeverityTemplate = _.template("""
    <ul class="popover pop-severity">
        <% _.each(severities, function(severity) { %>
        <li><a href="" class="severity" title="<%- severity.name %>"
               data-severity-id="<%- severity.id %>"><%- severity.name %></a></li>
        <% }); %>
    </ul>
    """)
    selectionPriorityTemplate = _.template("""
    <ul class="popover pop-priority">
        <% _.each(priorities, function(priority) { %>
        <li><a href="" class="priority" title="<%- priority.name %>"
               data-priority-id="<%- priority.id %>"><%- priority.name %></a></li>
        <% }); %>
    </ul>
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

        renderIssuestatus = (issue) ->
            owner = $scope.usersById?[issue.owner]
            date = moment(issue.created_date).format("DD MMM YYYY HH:mm")
            type = $scope.typeById[issue.type]
            status = $scope.statusById[issue.status]
            severity = $scope.severityById[issue.severity]
            priority = $scope.priorityById[issue.priority]
            html = template({
                owner: owner
                date: date
                editable: editable
                status: status
                severity: severity
                priority: priority
                type: type
            })
            $el.html(html)
            $el.find(".type-data").append(selectionTypeTemplate({types:$scope.typeList}))
            $el.find(".severity-data").append(selectionSeverityTemplate({severities:$scope.severityList}))
            $el.find(".priority-data").append(selectionPriorityTemplate({priorities:$scope.priorityList}))
            $el.find(".status-data").append(selectionStatusTemplate({statuses:$scope.statusList}))

        $scope.$watch $attrs.ngModel, (issue) ->
            if issue?
                renderIssuestatus(issue)

        if editable
            $el.on "click", ".type-data", (event) ->
                event.preventDefault()
                event.stopPropagation()
                $el.find(".pop-type").popover().open()

            $el.on "click", ".type", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                $model.$modelValue.type = target.data("type-id")
                renderIssuestatus($model.$modelValue)
                $.fn.popover().closeAll()

            $el.on "click", ".severity-data", (event) ->
                event.preventDefault()
                event.stopPropagation()
                $el.find(".pop-severity").popover().open()

            $el.on "click", ".severity", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                $model.$modelValue.severity = target.data("severity-id")
                renderIssuestatus($model.$modelValue)
                $.fn.popover().closeAll()

            $el.on "click", ".priority-data", (event) ->
                event.preventDefault()
                event.stopPropagation()
                $el.find(".pop-priority").popover().open()

            $el.on "click", ".priority", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                $model.$modelValue.priority = target.data("priority-id")
                renderIssuestatus($model.$modelValue)
                $.fn.popover().closeAll()

            $el.on "click", ".status-data", (event) ->
                event.preventDefault()
                event.stopPropagation()
                $el.find(".pop-status").popover().open()

            $el.on "click", ".status", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                $model.$modelValue.status = target.data("status-id")
                renderIssuestatus($model.$modelValue)
                $.fn.popover().closeAll()

    return {link:link, require:"ngModel"}

module.directive("tgIssueStatus", IssueStatusDirective)



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

IssueStatusButtonDirective = ($rootScope, $repo) ->
    # Display the status of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-status-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.statusById object

    template = _.template("""
    <div class="status-data clickable">
        <span class="level" style="background-color:<%= status.color %>"></span>
        <span class="status-status"><%= status.name %></span>
        <span class="icon icon-arrow-bottom"></span>
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
        render = (issue) =>
            status = $scope.statusById[issue.status]

            html = template({
                status: status
                statuses: $scope.statusList
            })
            $el.html(html)

        $el.on "click", ".status-data", (event) ->
            event.preventDefault()
            event.stopPropagation()

            $el.find(".pop-status").popover().open()

        $el.on "click", ".status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)

            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.status = target.data("status-id")

            $model.$setViewValue(issue)
            $repo.save($model.$modelValue).then ->
                $rootScope.$broadcast("history:reload")

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueStatusButton", ["$rootScope", "$tgRepo", IssueStatusButtonDirective])

#############################################################################
## Issue type button directive
#############################################################################

IssueTypeButtonDirective = ($rootScope, $repo) ->
    # Display the type of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-type-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.typeById object

    template = _.template("""
    <div class="type-data clickable">
        <span class="level" style="background-color:<%= type.color %>"></span>
        <span class="type-type"><%= type.name %></span>
        <span class="icon icon-arrow-bottom"></span>
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
        render = (issue) =>
            type = $scope.typeById[issue.type]

            html = template({
                type: type
                typees: $scope.typeList
            })
            $el.html(html)

        $el.on "click", ".type-data", (event) ->
            event.preventDefault()
            event.stopPropagation()

            $el.find(".pop-type").popover().open()

        $el.on "click", ".type", (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)

            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.type = target.data("type-id")

            $model.$setViewValue(issue)
            $repo.save($model.$modelValue).then ->
                $rootScope.$broadcast("history:reload")

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueTypeButton", ["$rootScope", "$tgRepo", IssueTypeButtonDirective])


#############################################################################
## Issue severity button directive
#############################################################################

IssueSeverityButtonDirective = ($rootScope, $repo) ->
    # Display the severity of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-severity-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.severityById object

    template = _.template("""
    <div class="severity-data clickable">
        <span class="level" style="background-color:<%= severity.color %>"></span>
        <span class="severity-severity"><%= severity.name %></span>
        <span class="icon icon-arrow-bottom"></span>
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
        render = (issue) =>
            severity = $scope.severityById[issue.severity]

            html = template({
                severity: severity
                severityes: $scope.severityList
            })
            $el.html(html)

        $el.on "click", ".severity-data", (event) ->
            event.preventDefault()
            event.stopPropagation()

            $el.find(".pop-severity").popover().open()

        $el.on "click", ".severity", (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)

            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.severity = target.data("severity-id")

            $model.$setViewValue(issue)
            $repo.save($model.$modelValue).then ->
                $rootScope.$broadcast("history:reload")

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueSeverityButton", ["$rootScope", "$tgRepo", IssueSeverityButtonDirective])


#############################################################################
## Issue priority button directive
#############################################################################

IssuePriorityButtonDirective = ($rootScope, $repo) ->
    # Display the priority of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-priority-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.priorityById object

    template = _.template("""
    <div class="priority-data clickable">
        <span class="level" style="background-color:<%= priority.color %>"></span>
        <span class="priority-priority"><%= priority.name %></span>
        <span class="icon icon-arrow-bottom"></span>
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
        render = (issue) =>
            priority = $scope.priorityById[issue.priority]

            html = template({
                priority: priority
                priorityes: $scope.priorityList
            })
            $el.html(html)

        $el.on "click", ".priority-data", (event) ->
            event.preventDefault()
            event.stopPropagation()

            $el.find(".pop-priority").popover().open()

        $el.on "click", ".priority", (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)

            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.priority = target.data("priority-id")

            $model.$setViewValue(issue)
            $repo.save($model.$modelValue).then ->
                $rootScope.$broadcast("history:reload")

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssuePriorityButton", ["$rootScope", "$tgRepo", IssuePriorityButtonDirective])


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
