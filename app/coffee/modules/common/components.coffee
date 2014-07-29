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
# File: modules/common/components.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce

module = angular.module("taigaCommon")

#############################################################################
## Date Range Directive (used mainly for sprint date range)
#############################################################################

DateRangeDirective = ->
    renderRange = ($el, first, second) ->
        initDate = moment(first).format("YYYY/MM/DD")
        endDate = moment(second).format("YYYY/MM/DD")
        $el.html("#{initDate}-#{endDate}")

    link = ($scope, $el, $attrs) ->
        [first, second] = $attrs.tgDateRange.split(",")

        bindOnce $scope, first, (valFirst) ->
            bindOnce $scope, second, (valSecond) ->
                renderRange($el, valFirst, valSecond)

    return {link:link}

module.directive("tgDateRange", DateRangeDirective)


#############################################################################
## Sprint Progress Bar Directive
#############################################################################

SprintProgressBarDirective = ->
    renderProgress = ($el, percentage, visual_percentage) ->
        if $el.is(".current-progress")
            $el.css("width", "#{percentage}%")
        else
            $el.find(".current-progress").css("width", "#{visual_percentage}%")
            $el.find(".number").html("#{percentage} %")

    link = ($scope, $el, $attrs) ->
        bindOnce $scope, $attrs.tgSprintProgressbar, (sprint) ->
            closedPoints = sprint.closed_points
            totalPoints = sprint.total_points
            percentage = 0
            percentage = Math.round(100 * (closedPoints/totalPoints)) if totalPoints != 0
            visual_percentage = 0
            #Visual hack for .current-progress bar
            visual_percentage = Math.round(98 * (closedPoints/totalPoints)) if totalPoints != 0
            renderProgress($el, percentage, visual_percentage)

    return {link: link}

module.directive("tgSprintProgressbar", SprintProgressBarDirective)


#############################################################################
## Date Selector Directive (using pikaday)
#############################################################################

DateSelectorDirective =->
    link = ($scope, $el, $attrs, $model) ->
        picker = new Pikaday({field: $el[0]})

    return {
        link: link
        require: "ngModel"
    }

module.directive("tgDateSelector", DateSelectorDirective)


#############################################################################
## Watchers directive
#############################################################################

WatchersDirective = ($rootscope, $confirm) ->
    # TODO: i18n
    template = _.template("""
    <div class="watchers-header">
        <span class="title">watchers</span>
        <% if (editable) { %>
        <a href="" title="Add watcher" class="icon icon-plus add-watcher"></a>
        <% } %>
    </div>

    <% _.each(watchers, function(watcher) { %>
    <div class="watcher-single">
        <div class="watcher-avatar">
            <a class="avatar" href="" title="Assigned to">
                <img src="<%= watcher.photo %>" alt="<%- watcher.full_name_display %>">
            </a>
        </div>
        <div class="watcher-name">
            <span>
                <%- watcher.full_name_display %>
            </span>

            <% if (editable) { %>
            <a class="icon icon-delete"
               data-watcher-id="<%= watcher.id %>" href="" title="delete-watcher">
            </a>
            <% } %>
        </div>
    </div>
    <% }); %>
    """)

    link = ($scope, $el, $attrs, $model) ->
        editable = $attrs.editable?

        renderWatchers = (watchers) ->
            html = template({watchers: watchers, editable:editable})
            $el.html(html)

            if watchers.length == 0
                if editable
                    $el.find(".title").text("Add watchers")
                    $el.find(".watchers-header").addClass("no-watchers")
                else
                    $el.find(".watchers-header").hide()

        $scope.$watch $attrs.ngModel, (item) ->
            return if not item?
            watchers = _.map(item.watchers, (watcherId) -> $scope.usersById[watcherId])
            renderWatchers(watchers)

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
            $scope.$apply ->
                $rootscope.$broadcast("watcher:add", $model.$modelValue)

        $scope.$on "watcher:added", (ctx, watcherId) ->
            watchers = _.clone($model.$modelValue.watchers, false)
            watchers.push(watcherId)
            watchers = _.uniq(watchers)

            item = $model.$modelValue.clone()
            item.watchers = watchers

            $model.$setViewValue(item)

    return {link:link, require:"ngModel"}

module.directive("tgWatchers", ["$rootScope", "$tgConfirm", WatchersDirective])


#############################################################################
## Assigned to directive
#############################################################################

AssignedToDirective = ($rootscope, $confirm) ->
    # TODO: i18n
    template = _.template("""
    <% if (assignedTo) { %>
    <div class="user-avatar">
        <img src="<%= assignedTo.photo %>" alt="<%- assignedTo.full_name_display %>" />
    </div>
    <% } %>

    <div class="assigned-to">
        <span class="assigned-title">Assigned to</span>

        <a href="" title="edit assignment" class="user-assigned <% if (editable) { %> editable <% } %>">
        <% if (assignedTo) { %>
            <%- assignedTo.full_name_display %>
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

        $scope.$watch $attrs.ngModel, (instance) ->
            renderAssignedTo(instance)

        $el.on "click", ".user-assigned", (event) ->
            event.preventDefault()
            $scope.$apply ->
                $rootscope.$broadcast("assigned-to:add", $model.$modelValue)

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            title = "Remove assigned to"
            subtitle = ""

            $confirm.ask(title, subtitle).then =>
                $model.$modelValue.assigned_to  = null
                renderAssignedTo($model.$modelValue)

        $scope.$on "assigned-to:added", (ctx, userId) ->
            $model.$modelValue.assigned_to = userId
            renderAssignedTo($model.$modelValue)

    return {
        link:link,
        require:"ngModel"
    }


module.directive("tgAssignedTo", ["$rootScope", "$tgConfirm", AssignedToDirective])


#############################################################################
## Common list directives
#############################################################################
## NOTE: These directives are used in issues and search and are
##       completely bindonce, they only serves for visualization of data.
#############################################################################

ListItemIssueStatusDirective = ->
    link = ($scope, $el, $attrs) ->
        issue = $scope.$eval($attrs.tgListitemIssueStatus)
        bindOnce $scope, "issueStatusById", (issueStatusById) ->
            $el.html(issueStatusById[issue.status].name)

    return {link:link}


ListItemTaskStatusDirective = ->
    link = ($scope, $el, $attrs) ->
        task = $scope.$eval($attrs.tgListitemTaskStatus)
        bindOnce $scope, "taskStatusById", (taskStatusById) ->
            $el.html(taskStatusById[task.status].name)

    return {link:link}


ListItemUsStatusDirective = ->
    link = ($scope, $el, $attrs) ->
        us = $scope.$eval($attrs.tgListitemUsStatus)
        bindOnce $scope, "usStatusById", (usStatusById) ->
            $el.html(usStatusById[us.status].name)

    return {link:link}


ListItemAssignedtoDirective = ->
    template = _.template("""
    <figure class="avatar">
        <img src="<%= imgurl %>" alt="<%- name %>"/>
        <figcaption><%- name %></figcaption>
    </figure>
    """)

    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "membersById", (membersById) ->
            item = $scope.$eval($attrs.tgListitemAssignedto)
            ctx = {name: "Unassigned", imgurl: "/images/unnamed.png"}

            member = membersById[item.assigned_to]
            if member
                ctx.imgurl = member.photo
                ctx.name = member.full_name

            $el.html(template(ctx))

    return {link:link}


ListItemPriorityDirective = ->
    template = """
    <div class="level"></div>
    """

    link = ($scope, $el, $attrs) ->
        issue = $scope.$eval($attrs.tgListitemPriority)
        bindOnce $scope, "priorityById", (priorityById) ->
            priority = priorityById[issue.priority]

            domNode = $el.find("div.level")
            domNode.css("background-color", priority.color)
            domNode.addClass(priority.name.toLowerCase())
            domNode.attr("title", priority.name)

    return {
        link: link
        template: template
    }


ListItemSeverityDirective = ->
    template = """
    <div class="level"></div>
    """

    link = ($scope, $el, $attrs) ->
        issue = $scope.$eval($attrs.tgListitemSeverity)
        bindOnce $scope, "severityById", (severityById) ->
            severity = severityById[issue.severity]

            domNode = $el.find("div.level")
            domNode.css("background-color", severity.color)
            domNode.addClass(severity.name.toLowerCase())
            domNode.attr("title", severity.name)

    return {
        link: link
        template: template
    }


module.directive("tgListitemIssueStatus", ListItemIssueStatusDirective)
module.directive("tgListitemAssignedto", ListItemAssignedtoDirective)
module.directive("tgListitemPriority", ListItemPriorityDirective)
module.directive("tgListitemSeverity", ListItemSeverityDirective)
module.directive("tgListitemTaskStatus", ListItemTaskStatusDirective)
module.directive("tgListitemUsStatus", ListItemUsStatusDirective)
