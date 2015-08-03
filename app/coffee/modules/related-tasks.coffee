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
# File: modules/related-tasks.coffee
###

taiga = @.taiga
trim = @.taiga.trim
debounce = @.taiga.debounce

module = angular.module("taigaRelatedTasks", [])

RelatedTaskRowDirective = ($repo, $compile, $confirm, $rootscope, $loading, $template, $translate) ->
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
                $confirm.notify("success")
                $rootscope.$broadcast("related-tasks:update")

            promise.then null, =>
                currentLoading.finish()
                $el.find('input').val(task.subject)
                $confirm.notify("error")
            return promise

        renderEdit = (task) ->
            $el.html($compile(templateEdit({task: task}))($scope))

            $el.on "keyup", "input", (event) ->
                if event.keyCode == 13
                    saveTask($model.$modelValue).then ->
                        renderView($model.$modelValue)
                else if event.keyCode == 27
                    renderView($model.$modelValue)

            $el.on "click", ".icon-floppy", (event) ->
                saveTask($model.$modelValue).then ->
                    renderView($model.$modelValue)

            $el.on "click", ".cancel-edit", (event) ->
                renderView($model.$modelValue)

        renderView = (task) ->
            $el.off()

            perms = {
                modify_task: $scope.project.my_permissions.indexOf("modify_task") != -1
                delete_task: $scope.project.my_permissions.indexOf("delete_task") != -1
            }

            $el.html($compile(templateView({task: task, perms: perms}))($scope))

            $el.on "click", ".icon-edit", ->
                renderEdit($model.$modelValue)
                $el.find('input').focus().select()

            $el.on "click", ".delete-task", (event) ->
                title = $translate.instant("TASK.TITLE_DELETE_ACTION")
                task = $model.$modelValue
                message = task.subject

                $confirm.askOnDelete(title, message).then (finish) ->
                    promise = $repo.remove(task)
                    promise.then ->
                        finish()
                        $confirm.notify("success")
                        $scope.$emit("related-tasks:delete")

                    promise.then null, ->
                        $confirm.notify("error")

        $scope.$watch $attrs.ngModel, (val) ->
            return if not val
            renderView(val)

        $scope.$on "related-tasks:assigned-to-changed", ->
            $rootscope.$broadcast("related-tasks:update")

        $scope.$on "related-tasks:status-changed", ->
            $rootscope.$broadcast("related-tasks:update")

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link, require:"ngModel"}

module.directive("tgRelatedTaskRow", ["$tgRepo", "$compile", "$tgConfirm", "$rootScope", "$tgLoading", "$tgTemplate", "$translate", RelatedTaskRowDirective])

RelatedTaskCreateFormDirective = ($repo, $compile, $confirm, $tgmodel, $loading, $analytics, $template) ->
    template = $template.get("task/related-task-create-form.html", true)

    newTask = {
        subject: ""
        assigned_to: null
    }

    link = ($scope, $el, $attrs) ->
        createTask = debounce 2000, (task) ->
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
                $confirm.notify("success")

            promise.then null, ->
                $el.find('input').val(task.subject)
                currentLoading.finish()
                $confirm.notify("error")

            return promise

        render = ->
            $el.off()

            $el.html($compile(template())($scope))
            $el.find('input').focus().select()
            $el.addClass('active')

            $el.on "keyup", "input", (event)->
                if event.keyCode == 13
                    createTask(newTask).then ->
                        render()
                else if event.keyCode == 27
                    $el.html("")

            $el.on "click", ".icon-delete", (event)->
                $el.html("")

            $el.on "click", ".icon-floppy", (event)->
                createTask(newTask).then ->
                    $el.html("")

        taiga.bindOnce $scope, "us", (val) ->
            newTask["status"] = $scope.project.default_task_status
            newTask["project"] = $scope.project.id
            newTask["user_story"] = $scope.us.id
            $scope.newTask = $tgmodel.make_model("tasks", newTask)
            $el.html("")

        $scope.$on "related-tasks:show-form", ->
            render()

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}
module.directive("tgRelatedTaskCreateForm", ["$tgRepo", "$compile", "$tgConfirm", "$tgModel", "$tgLoading", "$tgAnalytics", "$tgTemplate", RelatedTaskCreateFormDirective])

RelatedTaskCreateButtonDirective = ($repo, $compile, $confirm, $tgmodel) ->
    template = _.template("""
        <a class="icon icon-plus related-tasks-buttons"></a>
    """)

    link = ($scope, $el, $attrs) ->
        $scope.$watch "project", (val) ->
            return if not val
            $el.off()
            if $scope.project.my_permissions.indexOf("add_task") != -1
                $el.html(template())
            else
                $el.html("")

            $el.on "click", ".icon", (event)->
                $scope.$emit("related-tasks:add-new-clicked")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}
module.directive("tgRelatedTaskCreateButton", ["$tgRepo", "$compile", "$tgConfirm", "$tgModel", RelatedTaskCreateButtonDirective])

RelatedTasksDirective = ($repo, $rs, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        loadTasks = ->
            return $rs.tasks.list($scope.projectId, null, $scope.usId).then (tasks) =>
                $scope.tasks = tasks
                return tasks

        $scope.$on "related-tasks:add", ->
            loadTasks().then ->
                $rootscope.$broadcast("related-tasks:update")

        $scope.$on "related-tasks:delete", ->
            loadTasks().then ->
                $rootscope.$broadcast("related-tasks:update")

        $scope.$on "related-tasks:add-new-clicked", ->
            $scope.$broadcast("related-tasks:show-form")

        taiga.bindOnce $scope, "us", (val) ->
            loadTasks()

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}
module.directive("tgRelatedTasks", ["$tgRepo", "$tgResources", "$rootScope", RelatedTasksDirective])

RelatedTaskAssignedToInlineEditionDirective = ($repo, $rootscope, popoverService) ->
    template = _.template("""
    <img src="<%- imgurl %>" alt="<%- name %>"/>
    <figcaption><%- name %></figcaption>
    """)

    link = ($scope, $el, $attrs) ->
        updateRelatedTask = (task) ->
            ctx = {name: "Unassigned", imgurl: "/images/unnamed.png"}
            member = $scope.usersById[task.assigned_to]
            if member
                ctx.imgurl = member.photo
                ctx.name = member.full_name_display

            $el.find(".avatar").html(template(ctx))
            $el.find(".task-assignedto").attr('title', ctx.name)

        $ctrl = $el.controller()
        task = $scope.$eval($attrs.tgRelatedTaskAssignedToInlineEdition)
        notAutoSave = $scope.$eval($attrs.notAutoSave)
        autoSave = !notAutoSave

        updateRelatedTask(task)

        $el.on "click", ".task-assignedto", (event) ->
            $rootscope.$broadcast("assigned-to:add", task)

        taiga.bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_task") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$on "assigned-to:added", debounce 2000, (ctx, userId, updatedRelatedTask) =>
            if updatedRelatedTask.id == task.id
                updatedRelatedTask.assigned_to = userId
                if autoSave
                    $repo.save(updatedRelatedTask).then ->
                        $scope.$emit("related-tasks:assigned-to-changed")
                updateRelatedTask(updatedRelatedTask)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgRelatedTaskAssignedToInlineEdition", ["$tgRepo", "$rootScope", RelatedTaskAssignedToInlineEditionDirective])
