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
trim = @.taiga.trim
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
        "$location"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location) ->
        @scope.issueRef = @params.issueref
        @scope.sectionName = "Issues"

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.statusList = project.issue_statuses
            @scope.statusById = groupBy(project.issue_statuses, (x) -> x.id)
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

            projSlug = @scope.project.slug
            prev = @scope.issue.neighbors.previous
            next = @scope.issue.neighbors.next

            @scope.previousUrl = "/project/#{projSlug}/issues/#{prev.ref}" if prev.id?
            @scope.nextUrl = "/project/#{@scope.project.slug}/issues/#{next.ref}" if next.id?

    loadHistory: ->
        return @rs.issues.history(@scope.issueId).then (history) =>
            for item in history.results
                # If description was modified take only the description_html field
                if item.values_diff.description?
                    item.values_diff.description = historyResult.values_diff.description_html

                delete item.values_diff.description_html
                delete item.values_diff.description_diff

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

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadIssue())
                      .then(=> @.loadHistory())

    getUserFullName: (userId) ->
        return @scope.usersById[userId]?.full_name_display

    getUserAvatar: (userId) ->
        return @scope.usersById[userId]?.photo

    countChanges: (comment) ->
        return _.keys(comment.values_diff).length

    getChangeText: (change) ->
        if _.isArray(change)
            return change.join(", ")
        return change

    buildChangesText: (comment) ->
        size = @.countChanges(comment)
        # TODO: i18n
        if size == 1
            return "Made #{size} change"
        return "Made #{size} changes"

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
                @location.path("/project/#{@scope.project.slug}/issues")

module.controller("IssueDetailController", IssueDetailController)


#############################################################################
## Issue Main Directive
#############################################################################

IssueDirective = ($tgrepo, $log, $location, $confirm) ->
    linkSidebar = ($scope, $el, $attrs, $ctrl) ->

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSidebar($scope, $el, $attrs, $ctrl)

        $el.on "click", ".save-issue", (event) ->
            $tgrepo.save($scope.issue).then ->
                $confirm.notify("success")
                $location.path("/project/#{$scope.project.slug}/issues/#{$scope.issue.ref}")

        $el.on "click", ".add-comment a.button-green", (event) ->
            event.preventDefault()
            $tgrepo.save($scope.issue).then ->
                $ctrl.loadHistory()

        $el.on "focus", ".add-comment textarea", (event) ->
            $(this).addClass('active')


        $el.on "click", ".us-activity-tabs li a", (event) ->
            $el.find(".us-activity-tabs li a").toggleClass("active")
            $el.find(".us-activity section").toggleClass("hidden")

    return {link:link}

module.directive("tgIssueDetail", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", IssueDirective])


#############################################################################
## TagLine (possible should be moved as generic directive)
#############################################################################

TagLineDirective = ($log) ->
    # Main directive template (rendered by angular)
    template = """
    <div class="tags-container"></div>
    <input type="text" placeholder="Write tag..." class="hidden"/>
    """

    # Tags template (rendered manually using lodash)
    templateTags = _.template("""
    <% _.each(tags, function(tag) { %>
        <div class="tag">
            <span class="tag-name"><%- tag.name %></span>
            <% if (editable) { %>
            <a href="" title="delete tag" class="icon icon-delete"></a>
            <% } %>
        </div>
    <% }); %>""")

    renderTags = ($el, tags, editable) ->
        tags = _.map(tags, (t) -> {name: t})
        html = templateTags({tags: tags, editable:editable})
        $el.find("div.tags-container").html(html)

    normalizeTags = (tags) ->
        tags = _.map(tags, trim)
        tags = _.map(tags, (x) -> x.toLowerCase())
        return _.uniq(tags)

    link = ($scope, $el, $attrs, $model) ->
        editable = if $attrs.editable == "true" then true else false

        $scope.$watch $attrs.ngModel, (val) ->
            return if not val
            renderTags($el, val, editable)

        $el.find("input").remove() if not editable

        $el.on "keyup", "input", (event) ->
            return if event.keyCode != 13
            target = angular.element(event.currentTarget)
            value = trim(target.val())

            if value.length <= 0
                return

            tags = _.clone($model.$modelValue, false)
            tags = [] if not tags?
            tags.push(value)

            target.val("")

            $scope.$apply ->
                $model.$setViewValue(normalizeTags(tags))

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            value = trim(target.siblings(".tag-name").text())

            if value.length <= 0
                return

            tags = _.clone($model.$modelValue, false)
            tags = _.pull(tags, value)

            $scope.$apply ->
                $model.$setViewValue(normalizeTags(tags))

    return {
        link:link,
        require:"ngModel"
        template: template
    }

module.directive("tgTagLine", ["$log", TagLineDirective])


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
        <div class="severity-data <% if (editable) { %>clickable<% } %>">
            <span class="level" style="background-color:<%= severity.color %>"></span>
            <span class="severity-status"><%= severity.name %></span>
            <span class="level-name">severity</span>
        </div>
        <div class="priority-data <% if (editable) { %>clickable<% } %>">
            <span class="level" style="background-color:<%= priority.color %>"></span>
            <span class="priority-status"><%= priority.name %></span>
            <span class="level-name">priority</span>
        </div>
        <div class="status-data <% if (editable) { %>clickable<% } %>">
            <span class="level" style="background-color:<%= status.color %>"></span>
            <span class="status-status"><%= status.name %></span>
            <span class="level-name">status</span>
        </div>
    </div>
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
            status = $scope.statusById[issue.status]
            severity = $scope.severityById[issue.severity]
            priority = $scope.priorityById[issue.priority]
            html = template({
                editable: editable
                status: status
                severity: severity
                priority: priority
            })
            $el.html(html)
            $el.find(".severity-data").append(selectionSeverityTemplate({severities:$scope.severityList}))
            $el.find(".priority-data").append(selectionPriorityTemplate({priorities:$scope.priorityList}))
            $el.find(".status-data").append(selectionStatusTemplate({statuses:$scope.statusList}))

        $scope.$watch $attrs.ngModel, (issue) ->
            if issue?
                renderIssuestatus(issue)

        if editable
            $el.on "click", ".severity-data", (event) ->
                event.preventDefault()
                event.stopPropagation()
                $el.find(".pop-severity").show()
                body = angular.element("body")
                body.one "click", (event) ->
                    $el.find(".popover").hide()

            $el.on "click", ".severity", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                $model.$modelValue.severity = target.data("severity-id")
                renderIssuestatus($model.$modelValue)
                $el.find(".popover").hide()

            $el.on "click", ".priority-data", (event) ->
                event.preventDefault()
                event.stopPropagation()
                $el.find(".pop-priority").show()
                body = angular.element("body")
                body.one "click", (event) ->
                    $el.find(".popover").hide()

            $el.on "click", ".priority", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                $model.$modelValue.priority = target.data("priority-id")
                renderIssuestatus($model.$modelValue)
                $el.find(".popover").hide()

            $el.on "click", ".status-data", (event) ->
                event.preventDefault()
                event.stopPropagation()
                $el.find(".pop-status").show()
                body = angular.element("body")
                body.one "click", (event) ->
                    $el.find(".popover").hide()

            $el.on "click", ".status", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                $model.$modelValue.status = target.data("status-id")
                renderIssuestatus($model.$modelValue)
                $el.find(".popover").hide()

    return {link:link, require:"ngModel"}

module.directive("tgIssueStatus", IssueStatusDirective)

#############################################################################
## Comment directive
#############################################################################

CommentDirective = ->
    link = ($scope, $el, $attrs, $model) ->
        $el.on "click", ".activity-title", (event) ->
            event.preventDefault()
            $el.find(".activity-inner").toggleClass("active")

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgComment", CommentDirective)
