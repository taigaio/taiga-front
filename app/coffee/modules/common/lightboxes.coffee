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
# File: modules/common/lightboxes.coffee
###

module = angular.module("taigaCommon")

bindOnce = @.taiga.bindOnce
timeout = @.taiga.timeout
debounce = @.taiga.debounce
sizeFormat = @.taiga.sizeFormat
trim = @.taiga.trim
normalizeString = @.taiga.normalizeString

#############################################################################
## Common Lightbox Services
#############################################################################

# the lightboxContent hide/show doesn't have sense because is an IE hack
class LightboxService extends taiga.Service
    constructor: (@animationFrame, @q, @rootScope) ->

    open: ($el, onClose, onEsc, ignoreEsc) ->
        @.onClose = onClose

        if _.isString($el)
            $el = $($el)
        defered = @q.defer()

        lightboxContent = $el.children().not(".close")
        lightboxContent.hide()

        @animationFrame.add ->
            $el.css('display', 'flex')

        @animationFrame.add ->
            $el.addClass("open")
            $el.one "transitionend", =>
                firstField = $el.find('input:not(.no-focus),textarea:not(.no-focus)').first()

                if firstField.length
                    firstField.focus()
                else if document.activeElement
                    $(document.activeElement).blur()

        @animationFrame.add =>
            lightboxContent.show()
            defered.resolve()

        if !ignoreEsc
            docEl = angular.element(document)
            docEl.on "keydown.lightbox", (e) =>
                code = if e.keyCode then e.keyCode else e.which
                if code == 27
                    if onEsc
                        @rootScope.$applyAsync(onEsc)
                    else
                        @.close($el)


        return defered.promise

    close: ($el) ->
        return new Promise (resolve) =>
            if _.isString($el)
                $el = $($el)
            docEl = angular.element(document)
            docEl.off(".lightbox")
            docEl.off(".keyboard-navigation") # Hack: to fix problems in the WYSIWYG textareas when press ENTER

            $el.addClass('close-started') # don't attach animations

            @animationFrame.add =>
                $el.addClass('close')

                $el.one "transitionend", =>
                    $el.removeAttr('style')
                    $el
                        .removeClass("open")
                        .removeClass('close')
                        .removeClass('close-started')

                    if @.onClose
                        @rootScope.$apply(@.onClose)

                    resolve()

            if $el.hasClass("remove-on-close")
                scope = $el.data("scope")
                scope.$destroy() if scope
                $el.remove()


    getLightboxOpen: ->
        return $(".lightbox.open:not(.close-started)")

    closeAll: ->
        docEl = angular.element(document)
        for lightboxEl in docEl.find(".lightbox.open")
            @.close($(lightboxEl))


module.service("lightboxService", ["animationFrame", "$q", "$rootScope", LightboxService])


class LightboxKeyboardNavigationService extends taiga.Service
    stop: ->
        docEl = angular.element(document)
        docEl.off(".keyboard-navigation")

    dispatch: ($el, code) ->
        activeElement = $el.find(".selected")

        # Key: enter
        if code == 13
            if $el.find(".user-list-single").length == 1
                $el.find('.user-list-single:first').trigger("click")
            else
                activeElement.trigger("click")

        # Key: down
        else if code == 40
            if not activeElement.length
                $el.find('.user-list-single:not(".is-active"):first').addClass('selected')
            else
                next = activeElement.next('.user-list-single')
                if next.length
                    activeElement.removeClass('selected')
                    next.addClass('selected')
        # Key: up
        else if code == 38
            if not activeElement.length
                $el.find('.user-list-single:last').addClass('selected')
            else
                prev = activeElement.prev('.user-list-single:not(".is-active")')

                if prev.length
                    activeElement.removeClass('selected')
                    prev.addClass('selected')

    init: ($el) ->
        @stop()
        docEl = angular.element(document)
        docEl.on "keydown.keyboard-navigation", (event) =>
            code = if event.keyCode then event.keyCode else event.which
            if code == 40 || code == 38 || code == 13
                event.preventDefault()
                @.dispatch($el, code)

module.service("lightboxKeyboardNavigationService", LightboxKeyboardNavigationService)


#############################################################################
## Generic Lighthbox Directive
#############################################################################

# This adds generic behavior to all blocks with lightbox class like
# close button event handlers.

LightboxDirective = (lightboxService) ->
    link = ($scope, $el, $attrs) ->

        if !$attrs.$attr.visible
            $el.on "click", ".close", (event) ->
                event.preventDefault()
                lightboxService.close($el)

    return {restrict: "C", link: link}

module.directive("lightbox", ["lightboxService", LightboxDirective])

#############################################################################
## Block Lightbox Directive
#############################################################################

# Issue/Userstory blocking message lightbox directive.

BlockLightboxDirective = ($rootscope, $tgrepo, $confirm, lightboxService, $loading, $modelTransform, $translate) ->
    link = ($scope, $el, $attrs, $model) ->
        title = $translate.instant($attrs.title)
        $el.find("h2.title").text(title)

        unblock = (finishCallback) =>
            transform = $modelTransform.save (item) ->
                item.is_blocked = false
                item.blocked_note = ""

                return item

            transform.then ->
                $confirm.notify("success")
                $rootscope.$broadcast("object:updated")
                finishCallback()

            transform.then null, ->
                $confirm.notify("error")
                item.revert()

            transform.finally ->
                finishCallback()

            return transform

        block = () ->
            currentLoading = $loading()
                .target($el.find(".button-green"))
                .start()

            transform = $modelTransform.save (item) ->
                item.is_blocked = true
                item.blocked_note = $el.find(".reason").val()

                return item

            transform.then ->
                $confirm.notify("success")
                $rootscope.$broadcast("object:updated")

            transform.then null, ->
                $confirm.notify("error")

            transform.finally ->
                currentLoading.finish()
                lightboxService.close($el)

        $scope.$on "block", ->
            $el.find(".reason").val($model.$modelValue.blocked_note)
            lightboxService.open($el)

        $scope.$on "unblock", (event, model, finishCallback) =>
            unblock(finishCallback)

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()

            block()

    return {
        templateUrl: "common/lightbox/lightbox-block.html"
        link: link
        require: "ngModel"
    }

module.directive("tgLbBlock", ["$rootScope", "$tgRepo", "$tgConfirm", "lightboxService", "$tgLoading", "$tgQueueModelTransformation", "$translate", BlockLightboxDirective])


#############################################################################
## Generic Lightbox Blocking-Message Input Directive
#############################################################################

BlockingMessageInputDirective = ($log, $template, $compile) ->
    template = $template.get("common/lightbox/lightbox-blocking-message-input.html", true)

    link = ($scope, $el, $attrs, $model) ->
        if not $attrs.watch
            return $log.error "No watch attribute on tg-blocking-message-input directive"

        $scope.$watch $attrs.watch, (value) ->
            if value is not undefined and value == true
                $el.find(".blocked-note").removeClass("hidden")
            else
                $el.find(".blocked-note").addClass("hidden")

    templateFn = ($el, $attrs) ->
        return template({ngmodel: $attrs.ngModel})

    return {
        template: templateFn
        link: link
        require: "ngModel"
        restrict: "EA"
    }

module.directive("tgBlockingMessageInput", ["$log", "$tgTemplate", "$compile", BlockingMessageInputDirective])


#############################################################################
## Creare Bulk Userstories Lightbox Directive
#############################################################################

CreateBulkUserstoriesDirective = ($repo, $rs, $rootscope, lightboxService, $loading, $model) ->
    link = ($scope, $el, attrs) ->
        form = null

        $scope.$on "usform:bulk", (ctx, projectId, status) ->
            form.reset() if form

            $scope.new = {
                projectId: projectId
                statusId: status
                bulk: ""
            }
            lightboxService.open($el)

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = $el.find("form").checksley({onlyOneErrorElement: true})
            if not form.validate()
                return

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $rs.userstories.bulkCreate($scope.new.projectId, $scope.new.statusId, $scope.new.bulk)
            promise.then (result) ->
                result =  _.map(result.data, (x) => $model.make_model('userstories', x))
                currentLoading.finish()
                $rootscope.$broadcast("usform:bulk:success", result)
                lightboxService.close($el)

            promise.then null, (data) ->
                currentLoading.finish()
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgLbCreateBulkUserstories", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "lightboxService",
    "$tgLoading",
    "$tgModel",
    CreateBulkUserstoriesDirective
])


#############################################################################
## AssignedTo Lightbox Directive
#############################################################################

AssignedToLightboxDirective = (lightboxService, lightboxKeyboardNavigationService, $template,
$compile, avatarService, $userListService) ->
    link = ($scope, $el, $attrs) ->
        selectedUser = null
        selectedItem = null
        usersTemplate = $template.get("common/lightbox/lightbox-assigned-to-users.html", true)

        render = (selected, text) ->
            users = $userListService.searchUsers(text, selected)

            visibleUsers = _.slice(users, 0, 5)
            visibleUsers = _.map visibleUsers, (user) ->
                user.avatar = avatarService.getAvatar(user)

            if selected
                selected.avatar = avatarService.getAvatar(selected) if selected

            ctx = {
                selected: selected
                users: _.slice(users, 0, 5)
                showMore: users.length > 5
            }

            html = usersTemplate(ctx)
            html = $compile(html)($scope)

            $el.find(".assigned-to-list").html(html)

        closeLightbox = () ->
            lightboxKeyboardNavigationService.stop()
            lightboxService.close($el)

        $scope.$on "assigned-to:add", (ctx, item) ->
            selectedItem = item
            assignedToId = item.assigned_to
            selectedUser = $scope.usersById[assignedToId]
            render(selectedUser)
            lightboxService.open($el).then ->
                $el.find('input').focus()
                lightboxKeyboardNavigationService.init($el)

        $scope.$watch "usersSearch", (searchingText) ->
            if searchingText?
                render(selectedUser, searchingText)
                $el.find('input').focus()

        $el.on "click", ".user-list-single", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            closeLightbox()

            $scope.$apply ->
                $scope.$broadcast("assigned-to:added", target.data("user-id"), selectedItem)
                $scope.usersSearch = null

        $el.on "click", ".remove-assigned-to", (event) ->
            event.preventDefault()
            event.stopPropagation()

            closeLightbox()

            $scope.$apply ->
                $scope.usersSearch = null
                $scope.$broadcast("assigned-to:added", null, selectedItem)

        $el.on "click", ".close", (event) ->
            event.preventDefault()

            closeLightbox()

            $scope.$apply ->
                $scope.usersSearch = null

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "common/lightbox/lightbox-assigned-to.html"
        link:link
    }

module.directive("tgLbAssignedto", ["lightboxService", "lightboxKeyboardNavigationService",
"$tgTemplate", "$compile", "tgAvatarService", "tgUserListService", AssignedToLightboxDirective])


#############################################################################
## Assigned Users Lightbox directive
#############################################################################

AssignedUsersLightboxDirective = ($repo, lightboxService, lightboxKeyboardNavigationService,
$template, $compile, avatarService, $userListService) ->
    link = ($scope, $el, $attrs) ->
        selectedUsers = []
        selectedItem = null
        usersTemplate = $template.get("common/lightbox/lightbox-assigned-users-users.html", true)

        # Render the specific list of users.
        render = (assignedUsersIds, text) ->
            users = $userListService.searchUsers(text)

            # Add selected users
            selected = []
            _.map users, (user) ->
                if user.id in assignedUsersIds
                    user.avatar = avatarService.getAvatar(user)
                    selected.push(user)

            # Filter users in searchs

            visible = []
            _.map users, (user) ->
                if user.id not in assignedUsersIds
                    user.avatar = avatarService.getAvatar(user)
                    visible.push(user)

            ctx = {
                selected: selected
                users:  _.slice(visible, 0, 5)
                showMore: users.length > 5
            }

            html = usersTemplate(ctx)
            html = $compile(html)($scope)
            $el.find(".assigned-to-list").html(html)

        closeLightbox = () ->
            lightboxKeyboardNavigationService.stop()
            lightboxService.close($el)

        $scope.$on "assigned-user:add", (ctx, item) ->
            selectedItem = item
            selectedUsers = item.assigned_users
            render(selectedUsers)

            lightboxService.open($el).then ->
                $el.find("input").focus()
                lightboxKeyboardNavigationService.init($el)

        $scope.$watch "usersSearch", (searchingText) ->
            if searchingText?
                render(selectedUsers, searchingText)
                $el.find('input').focus()

        $el.on "click", ".user-list-single", debounce 200, (event) ->
            closeLightbox()

            event.preventDefault()
            target = angular.element(event.currentTarget)

            $scope.$apply ->
                $scope.usersSearch = null
                $scope.$broadcast("assigned-user:added", target.data("user-id"), selectedItem)

        $el.on "click", ".remove-assigned-to", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            event.stopPropagation()

            $scope.$apply ->
                $scope.usersSearch = null
                $scope.$broadcast("assigned-user:deleted", target.data("user-id"), selectedItem)
            closeLightbox()

        $el.on "click", ".close", (event) ->
            event.preventDefault()

            closeLightbox()

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "common/lightbox/lightbox-assigned-users.html"
        link:link
    }

module.directive("tgLbAssignedUsers", ["$tgRepo", "lightboxService",
"lightboxKeyboardNavigationService", "$tgTemplate", "$compile", "tgAvatarService",
"tgUserListService", AssignedUsersLightboxDirective])


#############################################################################
## Watchers Lightbox directive
#############################################################################

WatchersLightboxDirective = ($repo, lightboxService, lightboxKeyboardNavigationService, $template, $compile, avatarService) ->
    link = ($scope, $el, $attrs) ->
        selectedItem = null
        usersTemplate = $template.get("common/lightbox/lightbox-assigned-to-users.html", true)

        # Get prefiltered users by text
        # and without now watched users.
        getFilteredUsers = (text="") ->
            _filterUsers = (text, user) ->
                if selectedItem && _.find(selectedItem.watchers, (x) -> x == user.id)
                    return false

                username = user.full_name_display.toUpperCase()
                text = text.toUpperCase()
                return _.includes(username, text)

            users = _.clone($scope.activeUsers, true)
            users = _.filter(users, _.partial(_filterUsers, text))
            return users

        # Render the specific list of users.
        render = (users) ->
            visibleUsers = _.slice(users, 0, 5)

            visibleUsers = _.map visibleUsers, (user) ->
                user.avatar = avatarService.getAvatar(user)

                return user

            ctx = {
                selected: false
                users: visibleUsers
                showMore: users.length > 5
            }

            html = usersTemplate(ctx)
            html = $compile(html)($scope)
            $el.find(".ticket-watchers").html(html)

        closeLightbox = () ->
            lightboxKeyboardNavigationService.stop()
            lightboxService.close($el)

        $scope.$on "watcher:add", (ctx, item) ->
            selectedItem = item

            users = getFilteredUsers()
            render(users)

            lightboxService.open($el).then ->
                $el.find("input").focus()
                lightboxKeyboardNavigationService.init($el)

        $scope.$watch "usersSearch", (searchingText) ->
            if not searchingText?
                return

            users = getFilteredUsers(searchingText)
            render(users)
            $el.find("input").focus()

        $el.on "click", ".user-list-single", debounce 200, (event) ->
            closeLightbox()

            event.preventDefault()
            target = angular.element(event.currentTarget)

            $scope.$apply ->
                $scope.usersSearch = null
                $scope.$broadcast("watcher:added", target.data("user-id"))

        $el.on "click", ".close", (event) ->
            event.preventDefault()

            closeLightbox()

            $scope.$apply ->
                $scope.usersSearch = null

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "common/lightbox/lightbox-users.html"
        link:link
    }

module.directive("tgLbWatchers", ["$tgRepo", "lightboxService", "lightboxKeyboardNavigationService", "$tgTemplate", "$compile", "tgAvatarService", WatchersLightboxDirective])


LightboxLeaveProjectWarningDirective = (lightboxService, $template, $compile) ->
    link = ($scope, $el, attrs) ->
        lightboxService.open($el)

    return {
        templateUrl: 'common/lightbox/lightbox-leave-project-warning.html',
        link: link,
        scope: true
    }

module.directive("tgLightboxLeaveProjectWarning", ["lightboxService", LightboxLeaveProjectWarningDirective])


#############################################################################
## Set Due Date Lightbox Directive
#############################################################################

SetDueDateDirective = ($rootscope, lightboxService, $loading, $translate, $confirm, $modelTransform) ->
    link = ($scope, $el, attrs) ->
        prettyDate = $translate.instant("COMMON.PICKERDATE.FORMAT")
        lightboxService.open($el)

        if ($scope.object.due_date)
            $scope.new_due_date = moment($scope.object.due_date).format(prettyDate)

        $el.on "click", ".suggestion", (event) ->
            target = angular.element(event.currentTarget)
            quantity = target.data('quantity')
            unit = target.data('unit')
            value = moment().add(quantity, unit).format(prettyDate)
            $el.find(".due-date").val(value)

        save = ->
            currentLoading = $loading()
                .target($el.find(".submit-button"))
                .start()

            if $scope.notAutoSave
                new_due_date = $('.due-date').val()
                $scope.object.due_date = if (new_due_date) \
                    then moment(new_due_date, prettyDate).format("YYYY-MM-DD") \
                    else null

                $scope.$apply()
                currentLoading.finish()
                lightboxService.close($el)
                return

            transform = $modelTransform.save (object) ->
                new_due_date = $('.due-date').val()
                object.due_date = if (new_due_date) \
                    then moment(new_due_date, prettyDate).format("YYYY-MM-DD") \
                    else null
                return object

            transform.then ->
                $confirm.notify("success")

            transform.then null, ->
                $confirm.notify("error")

            transform.finally ->
                currentLoading.finish()
                lightboxService.close($el)
                $rootscope.$broadcast("object:updated")

        $el.on "click", ".submit-button", (event) ->
            event.preventDefault()
            save()

        remove = ->
            title = $translate.instant("LIGHTBOX.DELETE_DUE_DATE.TITLE")
            subtitle = $translate.instant("LIGHTBOX.DELETE_DUE_DATE.SUBTITLE")
            message = moment($scope.object.due_date).format(prettyDate)

            $confirm.askOnDelete(title, message, subtitle).then (askResponse) ->
                askResponse.finish()
                $('.due-date').val(null)
                $scope.object.due_date_reason = null
                if $scope.notAutoSave
                    $scope.object.due_date = null
                    lightboxService.close($el)
                else
                    save()

        $el.on "click", ".delete-due-date", (event) ->
            event.preventDefault()
            remove()

    return {
        templateUrl: 'common/lightbox/lightbox-due-date.html',
        link: link,
        scope: true
    }

module.directive("tgLbSetDueDate", ["$rootScope", "lightboxService", "$tgLoading", "$translate", "$tgConfirm"
                                    "$tgQueueModelTransformation", SetDueDateDirective])



#############################################################################
## Create/Edit Lightbox Directive
#############################################################################

groupBy = @.taiga.groupBy

CreateEditDirective = (
$log, $repo, $model, $rs, $rootScope, lightboxService, $loading, $translate,
$confirm, $q, attachmentsService, $template, $compile) ->
    link = ($scope, $el, attrs) ->
        schema = null
        objType = null
        form = null

        attachmentsToAdd = Immutable.List()
        attachmentsToDelete = Immutable.List()

        schemas = {
            us: {
                objName: 'User Story',
                model: 'userstories',
                params: { include_attachments: true, include_tasks: true },
                data: (project) ->
                    return {
                        translationID: 'US'
                        translationIDPlural: 'US'
                        statusList: _.sortBy(project.us_statuses, "order")
                    }
                initialData: (data) ->
                    return {
                        project: data.project.id
                        subject: ""
                        description: ""
                        tags: []
                        points : {}
                        status: if data.statusId then data.statusId else data.project.default_us_status
                        is_archived: false
                    }
            }
            task: {
                objName: 'Task',
                model: 'tasks',
                params: { include_attachments: true },
                data: (project) ->
                    return {
                        translationID: 'TASK'
                        translationIDPlural: 'TASKS'
                        statusList: _.sortBy(project.task_statuses, "order")
                    }
                initialData: (data) ->
                    return {
                        project: data.project.id
                        subject: ""
                        description: ""
                        assigned_to: null
                        tags: []
                        milestone: data.sprintId
                        status: data.project.default_task_status
                        user_story: data.usId
                        is_archived: false
                    }
            },
            issue: {
                objName: 'Issue',
                model: 'issues',
                params: { include_attachments: true },
                data: (project) ->
                    return {
                        translationID: 'ISSUE'
                        translationIDPlural: 'ISSUES'
                        project: project
                        statusList: _.sortBy(project.issue_statuses, "order")
                        typeById: groupBy(project.issue_types, (x) -> x.id)
                        typeList: _.sortBy(project.issue_types, "order")
                        severityById: groupBy(project.severities, (x) -> x.id)
                        severityList: _.sortBy(project.severities, "order")
                        priorityById: groupBy(project.priorities, (x) -> x.id)
                        priorityList: _.sortBy(project.priorities, "order")
                        milestonesById: groupBy(project.milestones, (x) -> x.id)
                    }
                initialData: (data) ->
                    return {
                        assigned_to: null
                        milestone: data.sprintId
                        priority: data.project.default_priority
                        project: data.project.id
                        severity: data.project.default_severity
                        status: data.project.default_issue_status
                        subject: ""
                        tags: []
                        type: data.project.default_issue_type
                    }
            }
        }

        $scope.setMode = (value) ->
            $scope.mode = value

        $scope.$on "genericform:new", (ctx, params) ->
            getSchema(params)
            $scope.mode = 'new'
            $scope.getOrCreate = false
            mount(params)

        $scope.$on "genericform:new-or-existing", (ctx, params) ->
            getSchema(params)
            $scope.mode = 'add-existing'
            $scope.getOrCreate = true
            $scope.existingFilterText = ''

            $rs[schema.model].listInAllProjects({ project: $scope.project.id }, true).then (data) ->
                $scope.existingItems = angular.copy(data)
            mount(params)

        $scope.$on "genericform:edit", (ctx, params) ->
            getSchema(params)
            $scope.mode = 'edit'
            $scope.getOrCreate = false
            mount(params)

        getSchema = (params) ->
            _.map params, (value, key) ->
                $scope[key] = value

            if !$scope.objType || !schemas[$scope.objType]
                return $log.error("Invalid objType `#{$scope.objType}` for `genericform` event")
            schema = schemas[$scope.objType]

        mount = (params) ->
            $scope.objName = schema.objName
            if $scope.mode == 'edit'
                $scope.obj = params.obj
                $scope.attachments = Immutable.fromJS(params.attachments)
            else
                $scope.obj = $model.make_model(schema.model, schema.initialData(params))
                $scope.attachments = Immutable.List()

            _.map schema.data($scope.project), (value, key) ->
                $scope[key] = value

            form.reset() if form
            resetAttachments()
            setStatus($scope.obj.status)
            render()
            $scope.lightboxOpen = true
            lightboxService.open($el, null, null, true)

        resetAttachments = () ->
            attachmentsToAdd = Immutable.List()
            attachmentsToDelete = Immutable.List()

        $scope.addAttachment = (attachment) ->
            attachmentsToAdd = attachmentsToAdd.push(attachment)

        $scope.deleteAttachment = (attachment) ->
            attachmentsToAdd = attachmentsToAdd.filter (it) ->
                return it.get('name') != attachment.get('name')

            if attachment.get("id")
                attachmentsToDelete = attachmentsToDelete.push(attachment)

        $scope.addTag = (tag, color) ->
            value = trim(tag.toLowerCase())
            tags = $scope.project.tags
            projectTags = $scope.project.tags_colors

            tags = [] if not tags?
            projectTags = {} if not projectTags?

            if value not in tags
                tags.push(value)

            projectTags[tag] = color || null
            $scope.project.tags = tags

            itemtags = _.clone($scope.obj.tags)
            inserted = _.find itemtags, (it) -> it[0] == value

            if !inserted
                itemtags.push([value , color])
                $scope.obj.tags = itemtags

        $scope.deleteTag = (tag) ->
            value = trim(tag[0].toLowerCase())
            tags = $scope.project.tags
            itemtags = _.clone($scope.obj.tags)

            _.remove itemtags, (tag) -> tag[0] == value
            $scope.obj.tags = itemtags
            _.pull($scope.obj.tags, value)

        createAttachments = (obj) ->
            promises = _.map attachmentsToAdd.toJS(), (attachment) ->
                attachmentsService.upload(attachment.file, obj.id, $scope.obj.project, $scope.objType)
            return $q.all(promises)

        deleteAttachments = (obj) ->
            promises = _.map attachmentsToDelete.toJS(), (attachment) ->
                return attachmentsService.delete($scope.objType, attachment.id)
            return $q.all(promises)

        addExistingToSprint = (item) ->
            currentLoading = $loading().target($el.find(".add-existing-button")).start()

            if item.milestone
                currentLoading.finish()
                lightboxService.close($el)
                sprintChangeConfirmAndSave(item)
            else
                onSuccess = ->
                    currentLoading.finish()
                    lightboxService.close($el)
                    $rootScope.$broadcast("#{$scope.objType}form:add:success", item)
                onError = ->
                    currentLoading.finish()
                    lightboxService.close($el)
                saveItem(item, onSuccess, onError)

        sprintChangeConfirmAndSave = (item) ->
            oldSprintName = $scope.milestonesById[item.milestone].name
            newSprintName = $scope.milestonesById[$scope.relatedObjectId].name
            title = $translate.instant("ISSUES.CONFIRM_CHANGE_FROM_SPRINT.TITLE")
            message = $translate.instant("ISSUES.CONFIRM_CHANGE_FROM_SPRINT.MESSAGE",
                {issue: item.subject, oldSprintName: oldSprintName, newSprintName: newSprintName})

            $confirm.ask(title, null, message).then (askResponse) ->
                onSuccess = ->
                    askResponse.finish()
                    lightboxService.close($el)
                    $rootScope.$broadcast("#{$scope.objType}form:add:success", item)

                onError = ->
                    askResponse.finish(false)
                    $confirm.notify("error")
                saveItem(item, onSuccess, onError)

        saveItem = (item, onSuccess, onError) ->
            item.setAttr($scope.relatedField, $scope.relatedObjectId)
            $repo.save(item, true).then(onSuccess, onError)


        isDisabledExisting = (item) ->
            return item && item[$scope.relatedField] == $scope.relatedObjectId

        $scope.isDisabledExisting = (selectedItem) ->
            isDisabledExisting(selectedItem)

        $scope.addExistingToSprint = (selectedItem) ->
            addExistingToSprint(selectedItem)

        submit = debounce 2000, (event) ->
            form = $el.find("form").checksley()
            if not form.validate()
                return

            currentLoading = $loading().target($el.find(".submit-button")).start()

            if $scope.mode == 'new'
                promise = $repo.create(schema.model, $scope.obj)
                broadcastEvent = "#{$scope.objType}form:new:success"
            else
                if ($scope.obj.due_date instanceof moment)
                    prettyDate = $translate.instant("COMMON.PICKERDATE.FORMAT")
                    $scope.obj.due_date = $scope.obj.due_date.format("YYYY-MM-DD")

                promise = $repo.save($scope.obj, true)
                broadcastEvent = "#{$scope.objType}form:edit:success"

            promise.then (data) ->
                deleteAttachments(data).then () ->
                    createAttachments(data).then () ->
                        currentLoading.finish()
                        close()
                        $rs[schema.model].getByRef(data.project, data.ref, schema.params).then (obj) ->
                            $rootScope.$broadcast(broadcastEvent, obj)
            promise.then null, (data) ->
                currentLoading.finish()
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        checkClose = () ->
            if !$scope.obj.isModified()
                close()
                $scope.$apply ->
                    $scope.obj.revert()
            else
                $confirm.ask(
                    $translate.instant("LIGHTBOX.CREATE_EDIT.CONFIRM_CLOSE"))
                    .then (result) ->
                        result.finish()
                        close()

        close = () ->
            lightboxService.close($el)
            $scope.lightboxOpen = false

        docEl = angular.element(document)
        docEl.on "keydown.lightbox-create-edit", (event) ->
            if $scope.lightboxOpen
                event.stopPropagation()
                code = if event.keyCode then event.keyCode else event.which
                if code == 27
                    checkClose()

        $el.on "submit", "form", submit

        $el.find('.close').on "click", (event) ->
            event.preventDefault()
            event.stopPropagation()
            checkClose()

        $el.on "click", ".status-dropdown", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $el.find(".pop-status").popover().open()

        $el.on "click", ".status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            setStatus(angular.element(event.currentTarget).data("status-id"))
            $scope.$apply()
            $scope.$broadcast("status:changed", $scope.obj.status)
            $el.find(".pop-status").popover().close()

        $el.on "click", ".team-requirement", (event) ->
            $scope.obj.team_requirement = not $scope.obj.team_requirement
            $scope.$apply()

        $el.on "click", ".client-requirement", (event) ->
            $scope.obj.client_requirement = not $scope.obj.client_requirement
            $scope.$apply()

        $el.on "click", ".is-blocked", (event) ->
            $scope.obj.is_blocked = not $scope.obj.is_blocked
            $scope.$apply()

        $el.on "click", ".iocaine", (event) ->
            $scope.obj.is_iocaine = not $scope.obj.is_iocaine
            $scope.$broadcast("isiocaine:changed", $scope.obj)

        $scope.isTeamRequirement = () ->
            return $scope.obj?.team_requirement

        $scope.isClientRequirement = () ->
            return $scope.obj?.client_requirement

        setStatus = (id) ->
            $scope.obj.status = id
            $scope.selectedStatus = _.find $scope.statusList, (item) -> item.id == id
            $scope.obj.is_closed = $scope.selectedStatus.is_closed

        render = (sprint) ->
            template = $template.get("common/lightbox/lightbox-create-edit/lb-create-edit.html")
            templateScope = $scope.$new()
            compiledTemplate = $compile(template)(templateScope)
            $el.html(compiledTemplate)

    return {
        link: link
    }

module.directive("tgLbCreateEdit", [
    "$log",
    "$tgRepo",
    "$tgModel",
    "$tgResources",
    "$rootScope",
    "lightboxService",
    "$tgLoading",
    "$translate",
    "$tgConfirm",
    "$q",
    "tgAttachmentsService",
    "$tgTemplate",
    "$compile",
    CreateEditDirective
])


#############################################################################
## RelateToEpic Lightbox Directive
#############################################################################

debounceLeading = @.taiga.debounceLeading

RelateToEpicLightboxDirective = ($rootScope, $confirm, lightboxService, $tgCurrentUserService
tgResources, $tgResources, $epicsService, tgAnalytics) ->
    link = ($scope, $el, $attrs) ->
        us = null

        $scope.projects = null
        $scope.projectEpics = Immutable.List()
        $scope.loading = false
        $scope.selectedProject = $scope.project.id

        newEpicForm = $el.find(".new-epic-form").checksley()
        existingEpicForm = $el.find(".existing-epic-form").checksley()

        loadProjects = ->
            if $scope.projects == null
                $scope.projects = $tgCurrentUserService.projects.get("unblocked")

        filterEpics = (selectedProjectId, filterText) ->
            tgResources.epics.listInAllProjects(
                {
                    is_epics_activated: true,
                    project__blocked_code: 'null',
                    project: selectedProjectId,
                    q: filterText
                }, true).then (data) ->
                    excludeIds = []
                    if (us.epics)
                        excludeIds = us.epics.map((epic) -> epic.id)
                    filteredData = data.filter((epic) -> excludeIds.indexOf(epic.get('id')) == -1)
                    $scope.projectEpics = filteredData

        selectProject = (selectedProjectId) ->
            $scope.selectedEpic = null
            $scope.searchEpic = ""
            filterEpics(selectedProjectId, $scope.searchEpic)

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            lightboxService.close($el)

        $scope.$on "relate-to-epic:add", (ctx, item) ->
            us = item
            $scope.selectedEpic = null
            $scope.searchEpic = ""
            loadProjects()
            filterEpics($scope.selectedProject, $scope.searchEpic).then () ->
                lightboxService.open($el).then ->
                    $el.find('input').focus

        $scope.$on "$destroy", ->
            $el.off()

        $scope.selectProject = (selectedProjectId) ->
            selectProject(selectedProjectId)

        $scope.onUpdateSearchEpic = debounceLeading 300, () ->
            $scope.selectedEpic = null
            filterEpics($scope.selectedProject, $scope.searchEpic)

        $scope.saveRelatedEpic = (selectedEpicId, onSavedRelatedEpic) ->
            return if not existingEpicForm.validate()

            $scope.loading = true

            onError = (data) ->
                $scope.loading = false
                $confirm.notify("error")
                existingEpicForm.setErrors(data)

            onSuccess = (data) ->
                tgAnalytics.trackEvent(
                    "user story related epic", "create", "create related epic on user story", 1)
                $scope.loading = false
                $rootScope.$broadcast("related-epics:changed", us)
                lightboxService.close($el)

            usId = us.id
            tgResources.epics.addRelatedUserstory(selectedEpicId, usId).then(
                onSuccess, onError)

        $scope.createEpic = (selectedProjectId, epicSubject) ->
            return if not newEpicForm.validate()

            @.loading = true

            onError = (data)->
                $scope.loading = false
                $confirm.notify("error")
                newEpicForm.setErrors(errors)

            onSuccess = () ->
                tgAnalytics.trackEvent(
                    "user story related epic", "create", "create related epic on user story", 1)
                $scope.loading = false
                $rootScope.$broadcast("related-epics:changed", us)
                lightboxService.close($el)

            onCreateEpic = (epic) ->
                epicId = epic.get('id')
                usId = us.id
                tgResources.epics.addRelatedUserstory(epicId, usId).then(onSuccess, onError)

            $epicsService.createEpic(
                {subject: epicSubject}, null, selectedProjectId).then(onCreateEpic, onError)

    return {
        templateUrl: "common/lightbox/lightbox-relate-to-epic.html"
        link:link
    }

module.directive("tgLbRelatetoepic", [
    "$rootScope", "$tgConfirm", "lightboxService", "tgCurrentUserService", "tgResources",
    "$tgResources", "tgEpicsService", "$tgAnalytics", RelateToEpicLightboxDirective])
