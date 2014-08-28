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

class IssueDetailController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.AttachmentsMixin)
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
        "$tgNavUrls"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @log, @appTitle, @navUrls) ->
        @.attachmentsUrlName = "issues/attachments"

        @scope.issueRef = @params.issueref
        @scope.sectionName = "Issue Details"

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set(@scope.issue.subject + " - " + @scope.project.name)

        promise.then null, ->
            console.log "FAIL" #TODO

        @scope.$on "attachment:create", @loadHistory
        @scope.$on "attachment:edit", @loadHistory
        @scope.$on "attachment:delete", @loadHistory

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

    loadHistory: =>
        return @rs.issues.history(@scope.issueId).then (history) =>
            _.each history.results, (historyResult) ->
                #If description was modified take only the description_html field
                if historyResult.values_diff.description?
                    historyResult.values_diff.description = historyResult.values_diff.description_diff

                delete historyResult.values_diff.description_html
                delete historyResult.values_diff.description_diff

            @scope.history = history.results
            @scope.comments = _.filter(history.results, (item) -> item.comment != "")

    loadInitialData: ->
        params = {
            pslug: @params.pslug
            issueref: @params.issueref
        }

        promise = @repo.resolve(params).then (data) =>
            @scope.projectId = data.project
            @scope.issueId = data.issue
            return data

        promise.then null, =>
            @location.path("/not-found")
            @location.replace()

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadIssue())
                      .then(=> @.loadAttachments(@scope.issueId))
                      .then(=> @.loadHistory())

    block: ->
        @rootscope.$broadcast("block", @scope.issue)

    unblock: ->
        @rootscope.$broadcast("unblock", @scope.issue)

    delete: ->
        # TODO: i18n
        title = "Delete Issue"
        subtitle = @scope.issue.subject

        @confirm.ask(title, subtitle).then =>
            @.repo.remove(@scope.issue).then =>
                @location.path(@navUrls.resolve("project-issues", {project: @scope.project.slug}))

module.controller("IssueDetailController", IssueDetailController)


#############################################################################
## Issue Main Directive
#############################################################################

IssueDirective = ($tgrepo, $log, $location, $confirm, $navUrls) ->
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
                $confirm.notify("success")
                ctx = {
                    project: $scope.project.slug
                    ref: $scope.issue.ref
                }
                $location.path($navUrls.resolve("project-issues-detail", ctx))

            onError = ->
                $confirm.notify("error")

            $tgrepo.save($scope.issue).then(onSuccess, onError)

        $el.on "click", ".add-comment a.button-green", (event) ->
            event.preventDefault()

            $el.find(".comment-list").addClass("activeanimation")

            onSuccess = ->
                $ctrl.loadHistory()

            onError = ->
                $confirm.notify("error")

            $tgrepo.save($scope.issue).then(onSuccess, onError)

        $el.on "focus", ".add-comment textarea", (event) ->
            $(this).addClass('active')

        $el.on "click", ".us-activity-tabs li a", (event) ->
            $el.find(".us-activity-tabs li a").toggleClass("active")
            $el.find(".us-activity section").toggleClass("hidden")

    return {link:link}

module.directive("tgIssueDetail", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", "$tgNavUrls",
                                   IssueDirective])


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
            type = $scope.typeById[issue.type]
            status = $scope.statusById[issue.status]
            severity = $scope.severityById[issue.severity]
            priority = $scope.priorityById[issue.priority]
            html = template({
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
