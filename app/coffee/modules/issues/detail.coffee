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
        "$tgNavUrls",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @log, @appTitle, @analytics, @navUrls, tgLoader) ->
        @scope.issueRef = @params.issueref
        @scope.sectionName = "Issue Details"
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set(@scope.issue.subject + " - " + @scope.project.name)
            @.initializeOnDeleteGoToUrl()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

        # Finally
        promise.finally tgLoader.pageLoaded

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

        @scope.$on "custom-attributes-values:edit", =>
            @rootscope.$broadcast("history:reload")

    initializeOnDeleteGoToUrl: ->
       ctx = {project: @scope.project.slug}
       if @scope.project.is_issues_activated
           @scope.onDeleteGoToUrl = @navUrls.resolve("project-issues", ctx)
       else
           @scope.onDeleteGoToUrl = @navUrls.resolve("project", ctx)

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            @scope.projectId = project.id
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
        return @rs.issues.getByRef(@scope.projectId, @params.issueref).then (issue) =>
            @scope.issue = issue
            @scope.issueId = issue.id
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
        promise = @.loadProject()
        return promise.then (project) =>
            @.fillUsersAndRoles(project.users, project.roles)
            @.loadIssue()


module.controller("IssueDetailController", IssueDetailController)


#############################################################################
## Issue status display directive
#############################################################################

IssueStatusDisplayDirective = ($template)->
    # Display if a Issue is open or closed and its issueboard status.
    #
    # Example:
    #     tg-issue-status-display(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.statusById object

    template = $template.get("common/components/status-display.html", true)

    link = ($scope, $el, $attrs) ->
        render = (issue) ->
            status = $scope.statusById[issue.status]

            html = template({
                is_closed: status.is_closed
                status: status
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

module.directive("tgIssueStatusDisplay", ["$tgTemplate", IssueStatusDisplayDirective])


#############################################################################
## Issue status button directive
#############################################################################

IssueStatusButtonDirective = ($rootScope, $repo, $confirm, $loading, $qqueue, $template) ->
    # Display the status of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-status-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.statusById object
    #   - $scope.project.my_permissions

    template = $template.get("issue/issues-status-button.html", true)

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

        save = $qqueue.bindAdd (statusId) =>
            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.status = statusId

            onSuccess = ->
                $confirm.notify("success")
                $model.$setViewValue(issue)
                $rootScope.$broadcast("history:reload")
                $loading.finish($el.find(".level-name"))
            onError = ->
                $confirm.notify("error")
                issue.revert()
                $model.$setViewValue(issue)
                $loading.finish($el.find(".level-name"))

            $loading.start($el.find(".level-name"))

            $repo.save(issue).then(onSuccess, onError)

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

            save(target.data("status-id"))

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueStatusButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQqueue", "$tgTemplate", IssueStatusButtonDirective])

#############################################################################
## Issue type button directive
#############################################################################

IssueTypeButtonDirective = ($rootScope, $repo, $confirm, $loading, $qqueue, $template) ->
    # Display the type of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-type-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.typeById object
    #   - $scope.project.my_permissions

    template = $template.get("issue/issue-type-button.html", true)

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

        save = $qqueue.bindAdd (type) =>
            $.fn.popover().closeAll()
            issue = $model.$modelValue.clone()
            issue.type = type

            onSuccess = ->
                $confirm.notify("success")
                $model.$setViewValue(issue)
                $rootScope.$broadcast("history:reload")
                $loading.finish($el.find(".level-name"))

            onError = ->
                $confirm.notify("error")
                issue.revert()
                $model.$setViewValue(issue)
                $loading.finish($el.find(".level-name"))
            $loading.start($el.find(".level-name"))

            $repo.save(issue).then(onSuccess, onError)

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
            type = target.data("type-id")
            save(type)

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueTypeButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQqueue", "$tgTemplate", IssueTypeButtonDirective])


#############################################################################
## Issue severity button directive
#############################################################################

IssueSeverityButtonDirective = ($rootScope, $repo, $confirm, $loading, $qqueue, $template) ->
    # Display the severity of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-severity-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.severityById object
    #   - $scope.project.my_permissions

    template = $template.get("issue/issue-severity-button.html", true)

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

        save = $qqueue.bindAdd (severity) =>
            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.severity = severity

            onSuccess = ->
                $confirm.notify("success")
                $model.$setViewValue(issue)
                $rootScope.$broadcast("history:reload")
                $loading.finish($el.find(".level-name"))
            onError = ->
                $confirm.notify("error")
                issue.revert()
                $model.$setViewValue(issue)
                $loading.finish($el.find(".level-name"))

            $loading.start($el.find(".level-name"))

            $repo.save(issue).then(onSuccess, onError)

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
            severity = target.data("severity-id")

            save(severity)

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueSeverityButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQqueue", "$tgTemplate", IssueSeverityButtonDirective])


#############################################################################
## Issue priority button directive
#############################################################################

IssuePriorityButtonDirective = ($rootScope, $repo, $confirm, $loading, $qqueue, $template) ->
    # Display the priority of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-priority-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.priorityById object
    #   - $scope.project.my_permissions

    template = $template.get("issue/issue-priority-button.html", true)

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

        save = $qqueue.bindAdd (priority) =>
            $.fn.popover().closeAll()

            issue = $model.$modelValue.clone()
            issue.priority = priority

            onSuccess = ->
                $confirm.notify("success")
                $model.$setViewValue(issue)
                $rootScope.$broadcast("history:reload")
                $loading.finish($el.find(".level-name"))
            onError = ->
                $confirm.notify("error")
                issue.revert()
                $model.$setViewValue(issue)
                $loading.finish($el.find(".level-name"))

            $loading.start($el.find(".level-name"))

            $repo.save(issue).then(onSuccess, onError)

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
            priority = target.data("priority-id")

            save(priority)

        $scope.$watch $attrs.ngModel, (issue) ->
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssuePriorityButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQqueue", "$tgTemplate", IssuePriorityButtonDirective])


#############################################################################
## Promote Issue to US button directive
#############################################################################

PromoteIssueToUsButtonDirective = ($rootScope, $repo, $confirm, $qqueue) ->
    link = ($scope, $el, $attrs, $model) ->

        save = $qqueue.bindAdd (issue, finish) =>
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


        $el.on "click", "a", (event) ->
            event.preventDefault()
            issue = $model.$modelValue

            title = "Promote this issue to a new user story" # TODO: i18n
            message = "Are you sure you want to create a new US from this Issue?" # TODO: i18n
            subtitle = issue.subject

            $confirm.ask(title, subtitle, message).then (finish) =>
                save(issue, finish)


        $scope.$on "$destroy", ->
            $el.off()

    return {
        restrict: "AE"
        require: "ngModel"
        templateUrl: "issue/promote-issue-to-us-button.html"
        link: link
    }

module.directive("tgPromoteIssueToUsButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgQqueue",
                                              PromoteIssueToUsButtonDirective])
