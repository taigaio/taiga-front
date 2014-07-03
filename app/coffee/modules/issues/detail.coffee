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
            @scope.issueStatusById = groupBy(project.issue_statuses, (x) -> x.id)
            @scope.severityById = groupBy(project.severities, (x) -> x.id)
            @scope.priorityById = groupBy(project.priorities, (x) -> x.id)
            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            return project

    loadIssue: ->
        return @rs.issues.get(@scope.projectId, @scope.issueId).then (issue) =>
            @scope.issue = issue
            return issue

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

IssueDirective = ($tgrepo, $log, $location) ->
    linkSidebar = ($scope, $el, $attrs, $ctrl) ->

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSidebar($scope, $el, $attrs, $ctrl)

        $el.on "click", ".save-issue", (event) ->
            $tgrepo.save($scope.issue).then ->
                console.log "TODO"

    return {link:link}


module.directive("tgIssueDetail", ["$tgRepo", "$log", "$tgLocation", IssueDirective])


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
## Watchers directive
#############################################################################

WatchersDirective = ($rootscope, $confirm) ->
    #TODO: i18n
    template = _.template("""
    <div class="watchers-header">
        <span class="title">watchers</span>
        <% if (editable) { %>
        <a href="" title="Add watcher" class="icon icon-plus add-watcher">
        </a>
        <% } %>
        <% _.each(watchers, function(watcher) { %>
        <div class="watcher-single">
            <div class="watcher-avatar">
                <a class="avatar" href="" title="Assigned to">
                    <img src="<%= watcher.photo %>" alt="<%= watcher.full_name_display %>">
                </a>
            </div>
            <div class="watcher-name">
                <a href="" title="<%= watcher.full_name_display %>">
                    <%= watcher.full_name_display %>
                </a>
                <% if (editable) { %>
                    <a class="icon icon-delete" data-watcher-id="<%= watcher.id %>" href="" title="delete-watcher">
                <% } %>
                </a>
            </div>
        </div>
        <% }); %>
    </div>""")

    link = ($scope, $el, $attrs, $model) ->
        editable = $attrs.editable?
        $scope.$watch $attrs.ngModel, (watcherIds) ->
            watchers = _.map(watcherIds, (watcherId) -> $scope.usersById[watcherId])
            html = template({watchers: watchers, editable:editable})
            $el.html(html)

        if not editable
            $el.find(".add-watcher").remove()

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            watcherId = target.data("watcher-id")
            title = "Remove watcher"
            subtitle = $scope.usersById[watcherId].full_name_display
            $confirm.ask(title, subtitle).then =>
                watcherIds = _.clone($model.$modelValue, false)
                watcherIds = _.pull(watcherIds, watcherId)
                $model.$setViewValue(watcherIds)

        $el.on "click", ".add-watcher", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            $rootscope.$broadcast("watcher:add")

        $scope.$on "watcher:added", (ctx, watcher) ->
            watcherIds = _.clone($model.$modelValue, false)
            watcherIds.push(watcher.id)
            watcherIds = _.uniq(watcherIds)
            $scope.$apply ->
                $model.$setViewValue(watcherIds)

    return {link:link, require:"ngModel"}

module.directive("tgWatchers", ["$rootScope", "$tgConfirm", WatchersDirective])

#############################################################################
## Assigned to directive
#############################################################################

AssignedToDirective = ($rootscope, $confirm) ->
    #TODO: i18n
    template = _.template("""
        <% if (assignedTo) { %>
        <div class="user-avatar">
            <a href="" title="Assigned to" class="avatar"><img src="<%= assignedTo.photo %>" alt="<%= assignedTo.full_name_display %>"></a>
        </div>
        <% } %>
        <div class="assigned-to">
            <span class="assigned-title">Assigned to</span>
            <a href="" title="edit assignment" class="user-assigned">
            <% if (assignedTo) { %>
                <%= assignedTo.full_name_display %>
            <% } else { %>
                Not assigned
            <% } %>
            <% if (editable) { %>
                <span class="icon icon-arrow-bottom"></span>
            <% } %>
            </a>
            <% if (editable) { %>
            <a href="" title="delete assignment" class="icon icon-delete"></a>
            <% } %>
        </div>
    """)

    link = ($scope, $el, $attrs, $model) ->
        editable = $attrs.editable?

        $scope.$watch $attrs.ngModel, (assignedToId) ->
            assignedTo = null
            assignedTo = $scope.usersById[assignedToId] if assignedToId?
            html = template({assignedTo: assignedTo, editable:editable})
            $el.html(html)

        $el.on "click", ".user-assigned", (event) ->
            event.preventDefault()
            $rootscope.$broadcast("assigned-to:add")

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            title = "Remove assigned to"
            subtitle = ""
            $confirm.ask(title, subtitle).then =>
                $model.$setViewValue(null)

        $scope.$on "assigned-to:added", (ctx, user) ->
            $scope.$apply ->
                $model.$setViewValue(user.id)


    return {link:link, require:"ngModel"}

module.directive("tgAssignedTo", ["$rootScope", "$tgConfirm", AssignedToDirective])
