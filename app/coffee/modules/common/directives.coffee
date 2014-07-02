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
# File: modules/common/directives.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce


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


DateSelectorDirective =->
    link = ($scope, $el, $attrs, $model) ->
        picker = new Pikaday({field: $el[0]})

    return {
        link: link
        require: "ngModel"
    }


#############################################################################
## User story status directive
#############################################################################


# TODO: change to less generic name.

UsStatusDirective = ($repo) ->
    ###
    Print the status of a US and a popover to change it.
    - tg-us-status: The user story
    - on-update: Method call after US is updated

    Example:

      div.status(tg-us-status="us" on-update="ctrl.loadSprintState()")
        a.us-status(href="", title="Status Name")

    NOTE: This directive need 'usStatusById' and 'project'.
    ###
    selectionTemplate = _.template("""
    <ul class="popover pop-status">
        <% _.forEach(statuses, function(status) { %>
        <li>
            <a href="" class="status" title="<%- status.name %>" data-status-id="<%- status.id %>">
                <%- status.name %>
            </a>
        </li>
        <% }); %>
    </ul>""")

    updateUsStatus = ($el, us, usStatusById) ->
        usStatusDomParent = $el.find(".us-status")
        usStatusDom = $el.find(".us-status .us-status-bind")
        usStatusDom.text(usStatusById[us.status].name)
        usStatusDomParent.css('color', usStatusById[us.status].color)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        us = $scope.$eval($attrs.tgUsStatus)

        taiga.bindOnce $scope, "project", (project) ->
            $el.append(selectionTemplate({ 'statuses':  project.us_statuses }))
            updateUsStatus($el, us, $scope.usStatusById)

        $el.on "click", ".us-status", (event) ->
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
            us.status = target.data("status-id")
            $el.find(".pop-status").hide()
            updateUsStatus($el, us, $scope.usStatusById)

            $scope.$apply () ->
                $repo.save(us).then ->
                    $scope.$eval($attrs.onUpdate)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


#############################################################################
## List directives (Issues List, Search)
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
    template = """
    <figure class="avatar">
        <img src="" alt="username"/>
        <figcaption>--</figcaption>
    </figure>
    """

    link = ($scope, $el, $attrs) ->
        issue = $scope.$eval($attrs.tgListitemAssignedto)
        if issue.assigned_to is null
            $el.find("figcaption").html("Unassigned")
        else
            bindOnce $scope, "membersById", (membersById) ->
                member = membersById[issue.assigned_to]
                $el.find("figcaption").html(member.full_name)
                $el.find("img").attr("src", member.photo)

    return {
        template: template
        link:link
    }


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


module = angular.module("taigaCommon")
module.directive("tgDateRange", DateRangeDirective)
module.directive("tgSprintProgressbar", SprintProgressBarDirective)
module.directive("tgDateSelector", DateSelectorDirective)
module.directive("tgUsStatus", ["$tgRepo", UsStatusDirective])

module.directive("tgListitemIssueStatus", ListItemIssueStatusDirective)
module.directive("tgListitemAssignedto", ListItemAssignedtoDirective)
module.directive("tgListitemPriority", ListItemPriorityDirective)
module.directive("tgListitemSeverity", ListItemSeverityDirective)
module.directive("tgListitemTaskStatus", ListItemTaskStatusDirective)
module.directive("tgListitemUsStatus", ListItemUsStatusDirective)
