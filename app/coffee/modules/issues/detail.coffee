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
            @scope.previousUrl = "/project/#{@scope.project.slug}/issues/#{@scope.issue.neighbors.previous.ref}" if @scope.issue.neighbors.previous.id?
            @scope.nextUrl = "/project/#{@scope.project.slug}/issues/#{@scope.issue.neighbors.next.ref}" if @scope.issue.neighbors.next.id?

    loadHistory: ->
        return @rs.issues.history(@scope.issueId).then (history) =>
            _.each history.results, (historyResult) ->
                #If description was modified take only the description_html field
                if historyResult.values_diff.description?
                    historyResult.values_diff.description = historyResult.values_diff.description_html
                    delete historyResult.values_diff.description_html
                    delete historyResult.values_diff.description_diff

            @scope.history = history.results
            @scope.comments = _.filter(history.results, (historyEntry) -> historyEntry.comment != "")

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
        return Object.keys(comment.values_diff).length

    getChangeText: (change) ->
        if _.isArray(change)
            return change.join(", ")
        return change

    buildChangesText: (comment) ->
        size = @.countChanges(comment)
        #TODO: i18n
        if size == 1
            return "Made #{size} change"

        return "Made #{size} changes"

    block: ->
        @rootscope.$broadcast("block", @scope.issue)

    unblock: ->
        @rootscope.$broadcast("unblock", @scope.issue)

    delete: ->
        #TODO: i18n
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
    </div>
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
                <a class="icon icon-delete" data-watcher-id="<%= watcher.id %>" href="" title="delete-watcher"></a>
            <% } %>
        </div>
    </div>
    <% }); %>
    """)

    link = ($scope, $el, $attrs, $model) ->
        editable = $attrs.editable?
        $scope.$watch $attrs.ngModel, (watcherIds) ->
            watchers = _.map(watcherIds, (watcherId) -> $scope.usersById[watcherId])
            html = template({watchers: watchers, editable:editable})
            $el.html(html)
            if watchers.length == 0
                if editable
                    $el.find(".title").text("Add watchers")
                    $el.find(".watchers-header").addClass("no-watchers")
                else
                    $el.find(".watchers-header").hide()

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
            <% if (editable && assignedTo!==null) { %>
            <a href="" title="delete assignment" class="icon icon-delete"></a>
            <% } %>
        </div>
    """)

    link = ($scope, $el, $attrs, $model) ->
        editable = $attrs.editable?

        renderAssignedTo = (issue) ->
            assignedToId = issue?.assigned_to
            assignedTo = null
            assignedTo = $scope.usersById[assignedToId] if assignedToId?
            html = template({assignedTo: assignedTo, editable:editable})
            $el.html(html)

        $scope.$watch $attrs.ngModel, (issue) ->
            renderAssignedTo(issue)

        $el.on "click", ".user-assigned", (event) ->
            event.preventDefault()
            $rootscope.$broadcast("assigned-to:add", $model.$modelValue)

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            title = "Remove assigned to"
            subtitle = ""
            $confirm.ask(title, subtitle).then =>
                $model.$setViewValue(null)

        $scope.$on "assigned-to:added", (ctx, issue) ->
            renderAssignedTo(issue)

    return {link:link, require:"ngModel"}

module.directive("tgAssignedTo", ["$rootScope", "$tgConfirm", AssignedToDirective])


#############################################################################
## Issue status directive
#############################################################################

IssueStatusDirective = () ->
    #TODO: i18n
    template = _.template("""
        <h1>
            <span>
            <% if (status.is_closed) { %>
            Closed
            <% } else { %>
            Open
            <% } %>
            <span class="us-detail-status"><%= status.name %></span>
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

CommentDirective = () ->
    link = ($scope, $el, $attrs, $model) ->
        $el.on "click", ".activity-title", (event) ->
            event.preventDefault()
            $el.find(".activity-inner").toggleClass("active")

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgComment", CommentDirective)

#############################################################################
## WYSIWYG markitup editor directive
#############################################################################

#TODO: fix when i18n is implemented
$i18next = {t: (key) -> key}

tgMarkitupDirective = ($rootscope, $rs) ->
    previewTemplate = _.template("""
      <div class="preview">
          <div class="actions">
              <a href="#" title="Edit">Edit</a>
          </div>
          <div class="content">
              <%= data %>
          </div>
      </div>
    """)

    link = ($scope, $el, $attrs, $model) ->
        element = angular.element($el)
        previewDomNode = $("<div/>", {class: "preview"})

        openHelp = () ->
            window.open($rootscope.urls.wikiHelpUrl(), '_blank')

        preview = () ->
            markdownDomNode = element.parents(".markdown")
            markItUpDomNode = element.parents(".markItUp")
            $rs.mdrender.render($scope.projectId, $model.$modelValue).then (data) ->
                markdownDomNode.append(previewTemplate({data: data.data}))
                markItUpDomNode.hide()

                element.parents(".markdown").one "click", ".preview", (event) ->
                    event.preventDefault()
                    markdownDomNode.find(".preview").remove()
                    markItUpDomNode.show()


        markdownSettings =
            nameSpace: 'markdown'
            onShiftEnter: {keepDefault:false, openWith:'\n\n'}
            markupSet: [
                {
                    name: $i18next.t('wiki-editor.heading-1')
                    key: "1"
                    placeHolder: $i18next.t('wiki-editor.placeholder')
                    closeWith: (markItUp) -> markdownTitle(markItUp, '=')
                },
                {
                    name: $i18next.t('wiki-editor.heading-2')
                    key: "2"
                    placeHolder: $i18next.t('wiki-editor.placeholder')
                    closeWith: (markItUp) -> markdownTitle(markItUp, '-')
                },
                {
                    name: $i18next.t('wiki-editor.heading-3')
                    key: "3"
                    openWith: '### '
                    placeHolder: $i18next.t('wiki-editor.placeholder')
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.bold')
                    key: "B"
                    openWith: '**'
                    closeWith: '**'
                },
                {
                    name: $i18next.t('wiki-editor.italic')
                    key: "I"
                    openWith: '_'
                    closeWith: '_'
                },
                {
                    name: $i18next.t('wiki-editor.strike')
                    key: "S"
                    openWith: '~~'
                    closeWith: '~~'
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.bulleted-list')
                    openWith: '- '
                },
                {
                    name: $i18next.t('wiki-editor.numeric-list')
                    openWith: (markItUp) -> markItUp.line+'. '
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.picture')
                    key: "P"
                    replaceWith: '![[![Alternative text]!]]([![Url:!:http://]!] "[![Title]!]")'
                },
                {
                    name: $i18next.t('wiki-editor.link')
                    key: "L"
                    openWith: '['
                    closeWith: ']([![Url:!:http://]!] "[![Title]!]")'
                    placeHolder: $i18next.t('wiki-editor.link-placeholder')
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.quotes')
                    openWith: '> '
                },
                {
                    name: $i18next.t('wiki-editor.code-block')
                    openWith: '```\n'
                    closeWith: '\n```'
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.preview')
                    call: preview
                    className: "preview-icon"
                },
                # {
                #     separator: '---------------'
                # },
                # {
                #     name: $i18next.t('wiki-editor.help')
                #     call: openHelp
                #     className: "help"
                # }
            ]
            afterInsert: (event) ->
                target = angular.element(event.textarea)
                $model.$setViewValue(target.val())

        markdownTitle = (markItUp, char) ->
            heading = ''
            n = $.trim(markItUp.selection or markItUp.placeHolder).length

            for i in [0..n-1]
                heading += char

            return '\n'+heading+'\n'

        element.markItUp(markdownSettings)

        element.on "keypress", (event) ->
            $scope.$apply()

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link, require:"ngModel"}

module.directive("tgMarkitup", ["$rootScope", "$tgResources", tgMarkitupDirective])
