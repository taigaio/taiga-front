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
        initDate = moment(first).format("DD MMM YYYY")
        endDate = moment(second).format("DD MMM YYYY")
        $el.html("#{initDate}-#{endDate}")

    link = ($scope, $el, $attrs) ->
        [first, second] = $attrs.tgDateRange.split(",")

        bindOnce $scope, first, (valFirst) ->
            bindOnce $scope, second, (valSecond) ->
                renderRange($el, valFirst, valSecond)

    return {link:link}

module.directive("tgDateRange", DateRangeDirective)


#############################################################################
## Date Selector Directive (using pikaday)
#############################################################################

DateSelectorDirective =->
    link = ($scope, $el, $attrs, $model) ->
        selectedDate = null
        $el.picker = new Pikaday({
          field: $el[0]
          format: "DD MMM YYYY"
          onSelect: (date) =>
              selectedDate = date
          onOpen: =>
              $el.picker.setDate(selectedDate) if selectedDate?
        })

        $scope.$watch $attrs.ngModel, (val) ->
            $el.picker.setDate(val) if val?

    return {
        link: link
        require: "ngModel"
    }

module.directive("tgDateSelector", DateSelectorDirective)


#############################################################################
## Sprint Progress Bar Directive
#############################################################################

SprintProgressBarDirective = ->
    renderProgress = ($el, percentage, visual_percentage) ->
        if $el.hasClass(".current-progress")
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
## Created-by display directive
#############################################################################

CreatedByDisplayDirective = ($template)->
    # Display the owner information (full name and photo) and the date of
    # creation of an object (like USs, tasks and issues).
    #
    # Example:
    #     div.us-created-by(tg-created-by-display, ng-model="us")
    #
    # Requirements:
    #   - model object must have the attributes 'created_date' and
    #     'owner'(ng-model)
    #   - scope.usersById object is required.

    template = $template.get("common/components/created-by.html", true) # TODO: i18n

    link = ($scope, $el, $attrs) ->
        render = (model) ->
            owner = $scope.usersById?[model.owner] or {
                full_name_display: "external user"
                photo: "/images/unnamed.png"
            }
            html = template({
                owner: owner
                date: moment(model.created_date).format("DD MMM YYYY HH:mm")
            })
            $el.html(html)

        bindOnce $scope, $attrs.ngModel, (model) ->
            render(model) if model?

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgCreatedByDisplay", ["$tgTemplate", CreatedByDisplayDirective])


#############################################################################
## Watchers directive
#############################################################################

WatchersDirective = ($rootscope, $confirm, $repo, $qqueue, $template) ->
    # You have to include a div with the tg-lb-watchers directive in the page
    # where use this directive
    #
    # TODO: i18n
    template = $template.get("common/components/watchers.html", true)

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project?.my_permissions?.indexOf($attrs.requiredPerm) != -1

        save = $qqueue.bindAdd (watchers) =>
            item = $model.$modelValue.clone()
            item.watchers = watchers
            $model.$setViewValue(item)

            promise = $repo.save($model.$modelValue)
            promise.then ->
                $confirm.notify("success")
                watchers = _.map(watchers, (watcherId) -> $scope.usersById[watcherId])
                renderWatchers(watchers)
                $rootscope.$broadcast("history:reload")

            promise.then null, ->
                $model.$modelValue.revert()

        deleteWatcher = $qqueue.bindAdd (watcherIds) =>
            item = $model.$modelValue.clone()
            item.watchers = watcherIds
            $model.$setViewValue(item)

            promise = $repo.save($model.$modelValue)
            promise.then ->
                $confirm.notify("success")
                watchers = _.map(item.watchers, (watcherId) -> $scope.usersById[watcherId])
                renderWatchers(watchers)
                $rootscope.$broadcast("history:reload")
            promise.then null, ->
                item.revert()
                $confirm.notify("error")


        renderWatchers = (watchers) ->
            ctx = {
                watchers: watchers
                isEditable: isEditable()
            }

            html = template(ctx)
            $el.html(html)

            if isEditable() and watchers.length == 0
                $el.find(".title").text("Add watchers")
                $el.find(".watchers-header").addClass("no-watchers")

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            return if not isEditable()
            target = angular.element(event.currentTarget)
            watcherId = target.data("watcher-id")

            title = "Delete watcher"
            message = $scope.usersById[watcherId].full_name_display

            $confirm.askOnDelete(title, message).then (finish) =>
                finish()

                watcherIds = _.clone($model.$modelValue.watchers, false)
                watcherIds = _.pull(watcherIds, watcherId)

                deleteWatcher(watcherIds)

        $el.on "click", ".add-watcher", (event) ->
            event.preventDefault()
            return if not isEditable()
            $scope.$apply ->
                $rootscope.$broadcast("watcher:add", $model.$modelValue)

        $scope.$on "watcher:added", (ctx, watcherId) ->
            watchers = _.clone($model.$modelValue.watchers, false)
            watchers.push(watcherId)
            watchers = _.uniq(watchers)

            save(watchers)

        $scope.$watch $attrs.ngModel, (item) ->
            return if not item?
            watchers = _.map(item.watchers, (watcherId) -> $scope.usersById[watcherId])
            renderWatchers(watchers)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link, require:"ngModel"}

module.directive("tgWatchers", ["$rootScope", "$tgConfirm", "$tgRepo", "$tgQqueue", "$tgTemplate", WatchersDirective])


#############################################################################
## Assigned to directive
#############################################################################

AssignedToDirective = ($rootscope, $confirm, $repo, $loading, $qqueue, $template) ->
    # You have to include a div with the tg-lb-assignedto directive in the page
    # where use this directive
    #
    # TODO: i18n
    template = $template.get("common/components/assigned-to.html", true)

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project?.my_permissions?.indexOf($attrs.requiredPerm) != -1

        save = $qqueue.bindAdd (userId) =>
            $model.$modelValue.assigned_to = userId

            $loading.start($el)

            promise = $repo.save($model.$modelValue)
            promise.then ->
                $loading.finish($el)
                $confirm.notify("success")
                renderAssignedTo($model.$modelValue)
                $rootscope.$broadcast("history:reload")
            promise.then null, ->
                $model.$modelValue.revert()
                $confirm.notify("error")
                $loading.finish($el)

            return promise

        renderAssignedTo = (issue) ->
            assignedToId = issue?.assigned_to
            assignedTo = if assignedToId? then $scope.usersById[assignedToId] else null

            ctx = {
                assignedTo: assignedTo
                isEditable: isEditable()
            }
            html = template(ctx)
            $el.html(html)

        $el.on "click", ".user-assigned", (event) ->
            event.preventDefault()
            return if not isEditable()
            $scope.$apply ->
                $rootscope.$broadcast("assigned-to:add", $model.$modelValue)

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            return if not isEditable()
            title = "Are you sure you want to leave it unassigned?" # TODO: i18n

            $confirm.ask(title).then (finish) =>
                finish()
                $model.$modelValue.assigned_to  = null
                save(null)

        $scope.$on "assigned-to:added", (ctx, userId, item) ->
            return if item.id != $model.$modelValue.id

            save(userId)

        $scope.$watch $attrs.ngModel, (instance) ->
            renderAssignedTo(instance)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link,
        require:"ngModel"
    }

module.directive("tgAssignedTo", ["$rootScope", "$tgConfirm", "$tgRepo", "$tgLoading", "$tgQqueue", "$tgTemplate", AssignedToDirective])


#############################################################################
## Block Button directive
#############################################################################

BlockButtonDirective = ($rootscope, $loading, $template) ->
    template = $template.get("common/components/block-button.html")

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_us") != -1

        $scope.$watch $attrs.ngModel, (item) ->
            return if not item

            if isEditable()
                $el.find('.item-block').addClass('editable')

            if item.is_blocked
                $el.find('.item-block').hide()
                $el.find('.item-unblock').show()
            else
                $el.find('.item-block').show()
                $el.find('.item-unblock').hide()

        $el.on "click", ".item-block", (event) ->
            event.preventDefault()
            $rootscope.$broadcast("block", $model.$modelValue)

        $el.on "click", ".item-unblock", (event) ->
            event.preventDefault()
            $loading.start($el.find(".item-unblock"))
            finish = ->
                $loading.finish($el.find(".item-unblock"))

            $rootscope.$broadcast("unblock", $model.$modelValue, finish)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
        template: template
    }

module.directive("tgBlockButton", ["$rootScope", "$tgLoading", "$tgTemplate", BlockButtonDirective])


#############################################################################
## Delete Button directive
#############################################################################

DeleteButtonDirective = ($log, $repo, $confirm, $location, $template) ->
    template = $template.get("common/components/delete-button.html")

    link = ($scope, $el, $attrs, $model) ->
        if not $attrs.onDeleteGoToUrl
            return $log.error "DeleteButtonDirective requires on-delete-go-to-url set in scope."
        if not $attrs.onDeleteTitle
            return $log.error "DeleteButtonDirective requires on-delete-title set in scope."

        $el.on "click", ".button", (event) ->
            title = $scope.$eval($attrs.onDeleteTitle)
            subtitle = $model.$modelValue.subject

            $confirm.askOnDelete(title, subtitle).then (finish) =>
                promise = $repo.remove($model.$modelValue)
                promise.then =>
                    finish()
                    url = $scope.$eval($attrs.onDeleteGoToUrl)
                    $location.path(url)
                promise.then null, =>
                    finish(false)
                    $confirm.notify("error")

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
        template: template
    }

module.directive("tgDeleteButton", ["$log", "$tgRepo", "$tgConfirm", "$tgLocation", "$tgTemplate", DeleteButtonDirective])


#############################################################################
## Editable subject directive
#############################################################################

EditableSubjectDirective = ($rootscope, $repo, $confirm, $loading, $qqueue, $template) ->
    template = $template.get("common/components/editable-subject.html")

    link = ($scope, $el, $attrs, $model) ->

        isEditable = ->
            return $scope.project.my_permissions.indexOf($attrs.requiredPerm) != -1

        save = $qqueue.bindAdd (subject) =>
            $model.$modelValue.subject = subject

            $loading.start($el.find('.save-container'))

            promise = $repo.save($model.$modelValue)
            promise.then ->
                $confirm.notify("success")
                $rootscope.$broadcast("history:reload")
                $el.find('.edit-subject').hide()
                $el.find('.view-subject').show()
            promise.then null, ->
                $confirm.notify("error")
            promise.finally ->
                $loading.finish($el.find('.save-container'))

            return promise

        $el.click ->
            return if not isEditable()
            $el.find('.edit-subject').show()
            $el.find('.view-subject').hide()
            $el.find('input').focus()

        $el.on "click", ".save", ->
            subject = $scope.item.subject
            save(subject)

        $el.on "keyup", "input", (event) ->
            if event.keyCode == 13
                subject = $scope.item.subject
                save(subject)
            else if event.keyCode == 27
                $scope.$apply () => $model.$modelValue.revert()

                $el.find('div.edit-subject').hide()
                $el.find('div.view-subject').show()

        $el.find('div.edit-subject').hide()
        $el.find('div.view-subject span.edit').hide()


        $scope.$watch $attrs.ngModel, (value) ->
            return if not value
            $scope.item = value

            if not isEditable()
                $el.find('.view-subject .edit').remove()

        $scope.$on "$destroy", ->
            $el.off()


    return {
        link: link
        restrict: "EA"
        require: "ngModel"
        template: template
    }

module.directive("tgEditableSubject", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgQqueue", "$tgTemplate", EditableSubjectDirective])


#############################################################################
## Editable subject directive
#############################################################################

EditableDescriptionDirective = ($rootscope, $repo, $confirm, $compile, $loading, $selectedText, $qqueue, $template) ->
    template = $template.get("common/components/editable-description.html") # TODO: i18n
    noDescriptionMegEditMode = $template.get("common/components/editable-description-msg-edit-mode.html") # TODO: i18n
    noDescriptionMegReadMode = $template.get("common/components/editable-description-msg-read-mode.html") # TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        $el.find('.edit-description').hide()
        $el.find('.view-description .edit').hide()

        isEditable = ->
            return $scope.project.my_permissions.indexOf($attrs.requiredPerm) != -1

        save = $qqueue.bindAdd (description) =>
            $model.$modelValue.description = description

            $loading.start($el.find('.save-container'))
            promise = $repo.save($model.$modelValue)
            promise.then ->
                $confirm.notify("success")
                $rootscope.$broadcast("history:reload")
                $el.find('.edit-description').hide()
                $el.find('.view-description').show()
            promise.then null, ->
                $confirm.notify("error")
            promise.finally ->
                $loading.finish($el.find('.save-container'))

        $el.on "mouseup", ".view-description", (event) ->
            # We want to dettect the a inside the div so we use the target and
            # not the currentTarget
            target = angular.element(event.target)
            return if not isEditable()
            return if target.is('a')
            return if $selectedText.get().length

            $el.find('.edit-description').show()
            $el.find('.view-description').hide()
            $el.find('textarea').focus()

        $el.on "click", ".save", ->
            description = $scope.item.description
            save(description)

        $el.on "keydown", "textarea", (event) ->
            if event.keyCode == 27
                $scope.$apply () => $scope.item.revert()
                $el.find('.edit-description').hide()
                $el.find('.view-description').show()

        $scope.$watch $attrs.ngModel, (value) ->
            return if not value
            $scope.item = value

            if isEditable()
                $el.find('.view-description .edit').show()
                $el.find('.view-description .us-content').addClass('editable')
                $scope.noDescriptionMsg = noDescriptionMegEditMode
            else
                $scope.noDescriptionMsg = noDescriptionMegReadMode

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
        template: template
    }

module.directive("tgEditableDescription", ["$rootScope", "$tgRepo", "$tgConfirm",
                                           "$compile", "$tgLoading", "$selectedText", "$tgQqueue", "$tgTemplate", EditableDescriptionDirective])


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


ListItemAssignedtoDirective = ($template) ->
    template = $template.get("common/components/list-item-assigned-to-avatar.html", true)

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

module.directive("tgListitemAssignedto", ["$tgTemplate", ListItemAssignedtoDirective])

ListItemPriorityDirective = ->
    link = ($scope, $el, $attrs) ->
        render = (priorityById, issue) ->
            priority = priorityById[issue.priority]
            domNode = $el.find(".level")
            domNode.css("background-color", priority.color)
            domNode.attr("title", priority.name)

        bindOnce $scope, "priorityById", (priorityById) ->
            issue = $scope.$eval($attrs.tgListitemPriority)
            render(priorityById, issue)

        $scope.$watch $attrs.tgListitemPriority, (issue) ->
            render($scope.priorityById, issue)

    return {
        link: link
        templateUrl: "common/components/level.html"
    }

module.directive("tgListitemPriority", ListItemPriorityDirective)

ListItemSeverityDirective = ->
    link = ($scope, $el, $attrs) ->
        render = (severityById, issue) ->
            severity = severityById[issue.severity]
            domNode = $el.find(".level")
            domNode.css("background-color", severity.color)
            domNode.attr("title", severity.name)

        bindOnce $scope, "severityById", (severityById) ->
            issue = $scope.$eval($attrs.tgListitemSeverity)
            render(severityById, issue)

        $scope.$watch $attrs.tgListitemSeverity, (issue) ->
            render($scope.severityById, issue)

    return {
        link: link
        templateUrl: "common/components/level.html"
    }


ListItemTypeDirective = ->
    link = ($scope, $el, $attrs) ->
        render = (issueTypeById, issue) ->
            type = issueTypeById[issue.type]
            domNode = $el.find(".level")
            domNode.css("background-color", type.color)
            domNode.attr("title", type.name)

        bindOnce $scope, "issueTypeById", (issueTypeById) ->
            issue = $scope.$eval($attrs.tgListitemType)
            render(issueTypeById, issue)

        $scope.$watch $attrs.tgListitemType, (issue) ->
            render($scope.issueTypeById, issue)

    return {
        link: link
        templateUrl: "common/components/level.html"
    }


#############################################################################
## Progress bar directive
#############################################################################

TgProgressBarDirective = ($template) ->
    template = $template.get("common/components/progress-bar.html", true)

    render = (el, percentage) ->
        el.html(template({percentage: percentage}))

    link = ($scope, $el, $attrs) ->
        element = angular.element($el)

        $scope.$watch $attrs.tgProgressBar, (percentage) ->
            percentage = _.max([0 , percentage])
            percentage = _.min([100, percentage])
            render($el, percentage)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgProgressBar", ["$tgTemplate", TgProgressBarDirective])

#############################################################################
## Main title directive
#############################################################################

TgMainTitleDirective = ($template) ->
    template = $template.get("common/components/main-title.html", true)

    render = (el, projectName, sectionName) ->
        el.html(template({
            projectName: projectName
            sectionName: sectionName
        }))
    link = ($scope, $el, $attrs) ->
        element = angular.element($el)
        $scope.$watch "project", (project) ->
            render($el, project.name, $scope.sectionName) if project

        $scope.$on "project:loaded", (ctx, project) =>
            render($el, project.name, $scope.sectionName)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgMainTitle", ["$tgTemplate", TgMainTitleDirective])

module.directive("tgListitemType", ListItemTypeDirective)
module.directive("tgListitemIssueStatus", ListItemIssueStatusDirective)
module.directive("tgListitemSeverity", ListItemSeverityDirective)
module.directive("tgListitemTaskStatus", ListItemTaskStatusDirective)
module.directive("tgListitemUsStatus", ListItemUsStatusDirective)
