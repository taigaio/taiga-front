###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
trim = @.taiga.trim
debounce = @.taiga.debounce

module = angular.module("taigaRelatedTasks", [])


RelatedTaskRowDirective = ($repo, $compile, $confirm, $rootscope, $loading, $template, $translate, $emojis) ->
    templateView = $template.get("task/related-task-row.html", true)
    templateEdit = $template.get("task/related-task-row-edit.html", true)

    link = ($scope, $el, $attrs, $model) ->
        saveTask = debounce 2000, (task) ->
            task.subject = $el.find('input').val()

            currentLoading = $loading()
                .target($el.find('.task-name'))
                .start()

            promise = $repo.save(task)
            promise.then =>
                currentLoading.finish()
                $rootscope.$broadcast("related-tasks:update")

            promise.then null, =>
                currentLoading.finish()
                $el.find('input').val(task.subject)
                $confirm.notify("error")
            return promise

        renderEdit = (task) ->
            if (@childScope)
                @childScope.$destroy()
            @childScope = $scope.$new()
            $el.off()
            $el.html($compile(templateEdit({task: task}))(childScope))

            $el.find(".task-name input").val(task.subject)

            $el.on "keyup", "input", (event) ->
                if event.keyCode == 13
                    saveTask($model.$modelValue).then ->
                        renderView($model.$modelValue)
                else if event.keyCode == 27
                    renderView($model.$modelValue)

            $el.on "click", ".save-task", (event) ->
                saveTask($model.$modelValue).then ->
                    renderView($model.$modelValue)

            $el.on "click", ".cancel-edit", (event) ->
                renderView($model.$modelValue)

        renderView = (task) ->
            perms = {
                modify_task: $scope.project.my_permissions.indexOf("modify_task") != -1
                delete_task: $scope.project.my_permissions.indexOf("delete_task") != -1
            }

            $el.html($compile(templateView({
                task: task,
                perms: perms,
                emojify: (text) -> $emojis.replaceEmojiNameByHtmlImgs(_.escape(text))
            }))($scope))

            $el.on "click", ".edit-task", ->
                renderEdit($model.$modelValue)
                $el.find('input').focus().select()

            $el.on "click", ".delete-task", (event) ->
                title = $translate.instant("TASK.TITLE_DELETE_ACTION")
                task = $model.$modelValue
                message = task.subject

                $confirm.askOnDelete(title, message).then (askResponse) ->
                    promise = $repo.remove(task)
                    promise.then ->
                        askResponse.finish()
                        $scope.$emit("related-tasks:delete")

                    promise.then null, ->
                        askResponse.finish(false)
                        $confirm.notify("error")

        $scope.$watch $attrs.ngModel, (val) ->
            return if not val

            $el.off()

            renderView(val)

        $scope.$on "related-tasks:assigned-to-changed", ->
            $rootscope.$broadcast("related-tasks:update")

        $scope.$on "related-tasks:status-changed", ->
            $rootscope.$broadcast("related-tasks:update")

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link, require:"ngModel"}

module.directive("tgRelatedTaskRow", ["$tgRepo", "$compile", "$tgConfirm", "$rootScope", "$tgLoading",
                                      "$tgTemplate", "$translate", "$tgEmojis", RelatedTaskRowDirective])


RelatedTaskCreateFormDirective = ($repo, $compile, $confirm, $tgmodel, $loading, $analytics) ->
    newTask = {
        subject: ""
        assigned_to: null
    }

    link = ($scope, $el, $attrs) ->
        createTask = (task) ->
            task.subject = $el.find('input').val()
            task.assigned_to = $scope.newTask.assigned_to
            task.status = $scope.newTask.status
            $scope.newTask.status = $scope.project.default_task_status
            $scope.newTask.assigned_to = null

            currentLoading = $loading()
                .target($el.find('.task-name'))
                .start()

            promise = $repo.create("tasks", task)
            promise.then ->
                $analytics.trackEvent("task", "create", "create task on userstory", 1)
                currentLoading.finish()
                $scope.$emit("related-tasks:add")

            promise.then null, ->
                $el.find('input').val(task.subject)
                currentLoading.finish()
                $confirm.notify("error")

            return promise

        close = () ->
            $el.off()

            $scope.openNewRelatedTask = false

        reset = () ->
            newTask = {
                subject: ""
                assigned_to: null
            }

            newTask["status"] = $scope.project.default_task_status
            newTask["project"] = $scope.project.id
            newTask["user_story"] = $scope.us.id

            $scope.newTask = $tgmodel.make_model("tasks", newTask)

        render = ->
            return if $scope.openNewRelatedTask

            $scope.openNewRelatedTask = true

            $el.on "submit", "form", (event)->
                event.preventDefault()
                createTask(newTask).then ->
                    reset()
                    $el.find('input').focus()

            $el.on "keyup", "input", (event)->
                if event.keyCode == 27
                    $scope.$apply () -> close()

        $scope.save = () ->
            createTask(newTask).then ->
                close()

        taiga.bindOnce $scope, "us", reset

        $scope.$on "related-tasks:show-form", ->
            $scope.$apply(render)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        scope: true,
        link: link,
        templateUrl: 'task/related-task-create-form.html'
    }

module.directive("tgRelatedTaskCreateForm", ["$tgRepo", "$compile", "$tgConfirm", "$tgModel", "$tgLoading",
                                             "$tgAnalytics", RelatedTaskCreateFormDirective])


RelatedTaskCreateButtonDirective = ($repo, $compile, $confirm, $tgmodel, $template) ->
    template = $template.get("common/components/add-button.html", true)

    link = ($scope, $el, $attrs) ->
        $scope.$watch "project", (val) ->
            return if not val
            $el.off()
            if $scope.project.my_permissions.indexOf("add_task") != -1
                $el.html($compile(template())($scope))
            else
                $el.html("")

            $el.on "click", ".add-button", (event)->
                $scope.$emit("related-tasks:add-new-clicked")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgRelatedTaskCreateButton", ["$tgRepo", "$compile", "$tgConfirm", "$tgModel",
                                               "$tgTemplate", RelatedTaskCreateButtonDirective])


RelatedTasksDirective = ($rootscope) ->
    link = ($scope, $el, $attrs) ->
        _isVisible = ->
            if $scope.project
                return $scope.project.my_permissions.indexOf("view_tasks") != -1
            return false

        _isEditable = ->
            if $scope.project
                return $scope.project.my_permissions.indexOf("modify_task") != -1
            return false

        $scope.reorderTask = (task, newIndex) ->
            $rootscope.$broadcast('task:reorder', task, newIndex)

        $scope.showAddTaks = ->
            if $scope.project
                return $scope.project.my_permissions.indexOf("add_task") != -1
            return false

        $scope.showRelatedTasks = ->
            return _isVisible()

        $scope.$on "related-tasks:add", ->
            $rootscope.$broadcast("related-tasks:update")

        $scope.$on "related-tasks:reordered", ->
            $rootscope.$broadcast("related-tasks:update")

        $scope.$on "related-tasks:delete", ->
            $rootscope.$broadcast("related-tasks:update")

        $scope.$on "related-tasks:add-new-clicked", ->
            $scope.$broadcast("related-tasks:show-form")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgRelatedTasks", ["$rootScope", RelatedTasksDirective])


RelatedTaskAssignedToInlineEditionDirective = ($repo, $rootscope, $translate, avatarService, $lightboxFactory) ->
    template = _.template("""
    <img style="background-color: <%- bg %>" src="<%- imgurl %>" alt="<%- name %>"/>
    <figcaption><%- name %></figcaption>
    """)

    link = ($scope, $el, $attrs) ->
        updateRelatedTask = (task) ->
            ctx = {
                name: $translate.instant("COMMON.ASSIGNED_TO.NOT_ASSIGNED"),
            }

            member = $scope.usersById[task.assigned_to]

            avatar = avatarService.getAvatar(member)
            ctx.imgurl = avatar.url
            ctx.bg = avatar.bg

            if member
                ctx.name = member.full_name_display

            $el.find(".avatar").html(template(ctx))
            $el.find(".task-assignedto").attr('title', ctx.name)

        $ctrl = $el.controller()
        task = $scope.$eval($attrs.tgRelatedTaskAssignedToInlineEdition)
        notAutoSave = $scope.$eval($attrs.notAutoSave)
        autoSave = !notAutoSave

        $scope.$watch $attrs.tgRelatedTaskAssignedToInlineEdition, () ->
            task = $scope.$eval($attrs.tgRelatedTaskAssignedToInlineEdition)
            updateRelatedTask(task)

        updateRelatedTask(task)

        $el.on "click", ".task-assignedto", (event) ->
            event.preventDefault()
            event.stopPropagation()

            onClose = (assignedUsers) =>
                task.assigned_to = assignedUsers.pop() || null
                if autoSave
                    $repo.save(task).then ->
                        $scope.$emit("related-tasks:assigned-to-changed")
                        updateRelatedTask(task)

            $lightboxFactory.create(
                'tg-lb-select-user',
                {
                    "class": "lightbox lightbox-select-user",
                },
                {
                    "currentUsers": [task.assigned_to],
                    "activeUsers": $scope.activeUsers,
                    "onClose": onClose,
                    "single": true,
                    "lbTitle": $translate.instant("COMMON.ASSIGNED_USERS.ADD"),
                }
            )

        taiga.bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_task") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgRelatedTaskAssignedToInlineEdition", ["$tgRepo", "$rootScope", "$translate", "tgAvatarService",
                                                          "tgLightboxFactory", RelatedTaskAssignedToInlineEditionDirective])
