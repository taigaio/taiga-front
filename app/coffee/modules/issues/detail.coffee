###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
bindMethods = @.taiga.bindMethods
normalizeString = @.taiga.normalizeString

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
        "tgAppMetaService",
        "$tgAnalytics",
        "$tgNavUrls",
        "$translate",
        "$tgQueueModelTransformation",
        "tgErrorHandlingService",
        "tgProjectService"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @log, @appMetaService, @analytics, @navUrls, @translate, @modelTransform,
                  @errorHandlingService, @projectService) ->
        bindMethods(@)

        @scope.issueRef = @params.issueref
        @scope.sectionName = @translate.instant("ISSUES.SECTION_NAME")
        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @._setMeta()
            @.initializeOnDeleteGoToUrl()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    _setMeta: ->
        title = @translate.instant("ISSUE.PAGE_TITLE", {
            issueRef: "##{@scope.issue.ref}"
            issueSubject: @scope.issue.subject
            projectName: @scope.project.name
        })
        description = @translate.instant("ISSUE.PAGE_DESCRIPTION", {
            issueStatus: @scope.statusById[@scope.issue.status]?.name or "--"
            issueType: @scope.typeById[@scope.issue.type]?.name or "--"
            issueSeverity: @scope.severityById[@scope.issue.severity]?.name or "--"
            issuePriority: @scope.priorityById[@scope.issue.priority]?.name or "--"
            issueDescription: angular.element(@scope.issue.description_html or "").text()
        })
        @appMetaService.setAll(title, description)

    initializeEventHandlers: ->
        @scope.$on "attachment:create", =>
            @analytics.trackEvent("attachment", "create", "create attachment on issue", 1)

        @scope.$on "promote-issue-to-us:success", =>
            @analytics.trackEvent("issue", "promoteToUserstory", "promote issue to userstory", 1)
            @rootscope.$broadcast("object:updated")
            @.loadIssue()

        @scope.$on "comment:new", =>
            @.loadIssue()

        @scope.$on "custom-attributes-values:edit", =>
            @rootscope.$broadcast("object:updated")

        @scope.$on "assign-sprint-to-issue:success", (ctx, milestoneId) =>
            @rootscope.$broadcast("object:updated")
            @scope.issue.milestone = milestoneId
            if milestoneId
                @.loadSprint()
            else
                @scope.sprint = null

    initializeOnDeleteGoToUrl: ->
       ctx = {project: @scope.project.slug}
       if @scope.project.is_issues_activated
           @scope.onDeleteGoToUrl = @navUrls.resolve("project-issues", ctx)
       else
           @scope.onDeleteGoToUrl = @navUrls.resolve("project", ctx)

    loadProject: ->
        project = @projectService.project.toJS()

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
        return project

    loadIssue: ->
        return @rs.issues.getByRef(@scope.projectId, @params.issueref).then (issue) =>
            @scope.issue = issue
            @scope.issueId = issue.id
            @scope.commentModel = issue

            @modelTransform.setObject(@scope, 'issue')

            if @scope.issue.neighbors.previous?.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.issue.neighbors.previous.ref
                }
                @scope.previousUrl = @navUrls.resolve("project-issues-detail", ctx)

            if @scope.issue.neighbors.next?.ref?
                ctx = {
                    project: @scope.project.slug
                    ref: @scope.issue.neighbors.next.ref
                }
                @scope.nextUrl = @navUrls.resolve("project-issues-detail", ctx)

    loadSprint: ->
        if @scope.issue.milestone
            return @rs.sprints.get(@scope.issue.project, @scope.issue.milestone).then (sprint) =>
                @scope.sprint = sprint
                return sprint

    loadInitialData: ->
        project = @.loadProject()

        @.fillUsersAndRoles(project.members, project.roles)

        return @.loadIssue().then(=> @.loadSprint())

    ###
    # Note: This methods (onUpvote() and onDownvote()) are related to tg-vote-button.
    #       See app/modules/components/vote-button for more info
    ###
    onUpvote: ->
        onSuccess = =>
            @.loadIssue()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.issues.upvote(@scope.issueId).then(onSuccess, onError)

    onDownvote: ->
        onSuccess = =>
            @.loadIssue()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.issues.downvote(@scope.issueId).then(onSuccess, onError)

    ###
    # Note: This methods (onWatch() and onUnwatch()) are related to tg-watch-button.
    #       See app/modules/components/watch-button for more info
    ###
    onWatch: ->
        onSuccess = =>
            @.loadIssue()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.issues.watch(@scope.issueId).then(onSuccess, onError)

    onUnwatch: ->
        onSuccess = =>
            @.loadIssue()
            @rootscope.$broadcast("object:updated")
        onError = =>
            @confirm.notify("error")

        return @rs.issues.unwatch(@scope.issueId).then(onSuccess, onError)

module.controller("IssueDetailController", IssueDetailController)


#############################################################################
## Issue status display directive
#############################################################################

IssueStatusDisplayDirective = ($template, $compile)->
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

            html = $compile(html)($scope)

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

module.directive("tgIssueStatusDisplay", ["$tgTemplate", "$compile", IssueStatusDisplayDirective])


#############################################################################
## Issue status button directive
#############################################################################

IssueStatusButtonDirective = ($rootScope, $repo, $confirm, $loading, $modelTransform, $template, $compile) ->
    # Display the status of Issue and you can edit it.
    #
    # Example:
    #     tg-issue-status-button(ng-model="issue")
    #
    # Requirements:
    #   - Issue object (ng-model)
    #   - scope.statusById object
    #   - $scope.project.my_permissions

    template = $template.get("common/components/status-button.html", true)

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

            html = $compile(html)($scope)

            $el.html(html)

        save = (statusId) ->
            $.fn.popover().closeAll()

            currentLoading = $loading()
                .target($el)
                .start()

            transform = $modelTransform.save (issue) ->
                issue.status = statusId

                return issue

            onSuccess = ->
                $rootScope.$broadcast("object:updated")
                currentLoading.finish()

            onError = ->
                $confirm.notify("error")
                currentLoading.finish()

            transform.then(onSuccess, onError)

        $el.on "click", ".js-edit-status", (event) ->
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

        $scope.$watch () ->
            return $model.$modelValue?.status
        , () ->
            issue = $model.$modelValue
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueStatusButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$compile", IssueStatusButtonDirective])

#############################################################################
## Issue type button directive
#############################################################################

IssueTypeButtonDirective = ($rootScope, $repo, $confirm, $loading, $modelTransform, $template, $compile) ->
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
        notAutoSave = $scope.$eval($attrs.notAutoSave)

        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_issue") != -1

        render = (issue) ->
            type = $scope.typeById[issue.type]

            html = template({
                type: type
                typees: $scope.typeList
                editable: isEditable()
            })

            html = $compile(html)($scope)

            $el.html(html)

        save = (type) ->
            $.fn.popover().closeAll()

            if notAutoSave
                $model.$modelValue.type = type
                $scope.$apply()
                return

            currentLoading = $loading()
                .target($el.find(".level-name"))
                .start()

            transform = $modelTransform.save (issue) ->
                issue.type = type

                return issue

            onSuccess = ->
                $rootScope.$broadcast("object:updated")
                currentLoading.finish()

            onError = ->
                $confirm.notify("error")
                currentLoading.finish()

            transform.then(onSuccess, onError)

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

        $scope.$watch () ->
            return $model.$modelValue?.type
        , () ->
            issue = $model.$modelValue
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueTypeButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$compile", IssueTypeButtonDirective])


#############################################################################
## Issue severity button directive
#############################################################################

IssueSeverityButtonDirective = ($rootScope, $repo, $confirm, $loading, $modelTransform, $template, $compile) ->
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
        notAutoSave = $scope.$eval($attrs.notAutoSave)

        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_issue") != -1

        render = (issue) ->
            severity = $scope.severityById[issue.severity]

            html = template({
                severity: severity
                severityes: $scope.severityList
                editable: isEditable()
            })

            html = $compile(html)($scope)

            $el.html(html)

        save = (severity) ->
            $.fn.popover().closeAll()

            if notAutoSave
                $model.$modelValue.severity = severity
                $scope.$apply()
                return

            currentLoading = $loading()
                .target($el.find(".level-name"))
                .start()

            transform = $modelTransform.save (issue) ->
                issue.severity = severity

                return issue

            onSuccess = ->
                $rootScope.$broadcast("object:updated")
                currentLoading.finish()

            onError = ->
                $confirm.notify("error")
                currentLoading.finish()

            transform.then(onSuccess, onError)

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

        $scope.$watch () ->
            return $model.$modelValue?.severity
        , () ->
            issue = $model.$modelValue
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssueSeverityButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$compile", IssueSeverityButtonDirective])


#############################################################################
## Issue priority button directive
#############################################################################

IssuePriorityButtonDirective = ($rootScope, $repo, $confirm, $loading, $modelTransform, $template, $compile) ->
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
        notAutoSave = $scope.$eval($attrs.notAutoSave)

        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_issue") != -1

        render = (issue) ->
            priority = $scope.priorityById[issue.priority]

            html = template({
                priority: priority
                priorityes: $scope.priorityList
                editable: isEditable()
            })

            html = $compile(html)($scope)

            $el.html(html)

        save = (priority) ->
            $.fn.popover().closeAll()

            if notAutoSave
                $model.$modelValue.priority = priority
                $scope.$apply()
                return

            currentLoading = $loading()
                .target($el.find(".level-name"))
                .start()

            transform = $modelTransform.save (issue) ->
                issue.priority = priority

                return issue

            onSuccess = ->
                $rootScope.$broadcast("object:updated")
                currentLoading.finish()

            onError = ->
                $confirm.notify("error")
                currentLoading.finish()

            transform.then(onSuccess, onError)

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

        $scope.$watch () ->
            return $model.$modelValue?.priority
        , () ->
            issue = $model.$modelValue
            render(issue) if issue

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgIssuePriorityButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$compile", IssuePriorityButtonDirective])


#############################################################################
## Promote Issue to US button directive
#############################################################################

PromoteIssueToUsButtonDirective = ($rootScope, $repo, $confirm, $translate) ->
    link = ($scope, $el, $attrs, $model) ->

        save = (issue, askResponse) =>
            data = {
                generated_from_issue: issue.id
                project: issue.project,
                subject: issue.subject
                description: issue.description
                tags: issue.tags
                is_blocked: issue.is_blocked
                blocked_note: issue.blocked_note
                due_date: issue.due_date
            }

            onSuccess = ->
                askResponse.finish()
                $confirm.notify("success")
                $rootScope.$broadcast("promote-issue-to-us:success")

            onError = ->
                askResponse.finish()
                $confirm.notify("error")

            $repo.create("userstories", data).then(onSuccess, onError)

        $el.on "click", "a", (event) ->
            event.preventDefault()
            issue = $model.$modelValue

            title = $translate.instant("ISSUES.CONFIRM_PROMOTE.TITLE")
            message = $translate.instant("ISSUES.CONFIRM_PROMOTE.MESSAGE")
            subtitle = issue.subject

            $confirm.ask(title, subtitle, message).then (response) =>
                save(issue, response)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        restrict: "AE"
        require: "ngModel"
        templateUrl: "issue/promote-issue-to-us-button.html"
        link: link
    }

module.directive("tgPromoteIssueToUsButton", ["$rootScope", "$tgRepo", "$tgConfirm", "$translate"
                                              PromoteIssueToUsButtonDirective])

#############################################################################
## Add Issue to Sprint button directive
#############################################################################

AssignSprintToIssueButtonDirective = ($rootScope, $rs, $repo, $loading, $translate,
lightboxService, $confirm) ->
    link = ($scope, $el, $attrs, $model) ->
        avaliableMilestones = []
        issue = null

        $el.on "click", ".assign-issue-button.button-unset", (event) ->
            event.preventDefault()
            event.stopPropagation()
            title = $translate.instant("ISSUES.ACTION_ATTACH_SPRINT")
            issue = $model.$modelValue
            $rs.sprints.list($scope.projectId, null).then (data) ->
                $scope.milestones = data.milestones
                $scope.selectedSprint = issue.milestone
                avaliableMilestones = angular.copy($scope.milestones)
                lightboxService.open($el.find(".lightbox-assign-sprint-to-issue"))

        $el.on "click", ".assign-issue-button.button-set", (event) ->
            event.preventDefault()
            event.stopPropagation()
            issue = $model.$modelValue
            $rs.sprints.list($scope.projectId, null).then (data) ->
                currentSprint = _.find(data.milestones, { "id": issue.milestone })

                title = $translate.instant("ISSUES.CONFIRM_DETACH_FROM_SPRINT.TITLE")
                message = $translate.instant("ISSUES.CONFIRM_DETACH_FROM_SPRINT.MESSAGE")
                message += " <strong>#{currentSprint.name}</strong>"

                $confirm.ask(title, null, message).then (askResponse) ->
                    onSuccess = ->
                        $scope.$broadcast("assign-sprint-to-issue:success", null)
                        askResponse.finish()
                        lightboxService.close($el)

                    onError = ->
                        askResponse.finish(false)
                        $confirm.notify("error")

                    issue.setAttr('milestone', null)
                    $repo.save(issue, true).then(onSuccess, onError)

        $scope.$on "$destroy", ->
            $el.off()

        existsMilestone = (needle, haystack) ->
            haystack = normalizeString(haystack.toUpperCase())
            needle = normalizeString(needle.toUpperCase())
            return _.includes(haystack, needle)

        $scope.filterMilestones = (filterText) ->
            $scope.milestones = avaliableMilestones.filter((milestone) ->
                existsMilestone(filterText, milestone.name)
            )

        $scope.saveIssueToSprint = (selectedSprint, event) ->
            currentLoading = $loading().target($(event.currentTarget)).start()
            issue.setAttr('milestone', selectedSprint.id)
            $repo.save(issue, true).then (data) ->
                currentLoading.finish()
                lightboxService.close($el.find(".lightbox-assign-sprint-to-issue"))
                $scope.$broadcast("assign-sprint-to-issue:success", selectedSprint.id)

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
        templateUrl: "issue/assign-sprint-to-issue-button.html"

    }

module.directive("tgAssignSprintToIssueButton", ["$rootScope", "$tgResources", "$tgRepo",
                "$tgLoading", "$translate", "lightboxService", "$tgConfirm"
                AssignSprintToIssueButtonDirective] )
