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
# File: modules/taskboard/lightboxes.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce
trim = @.taiga.trim

CreateEditTaskDirective = ($repo, $model, $rs, $rootscope, $loading, lightboxService, $translate, $q, $confirm, attachmentsService) ->
    link = ($scope, $el, attrs) ->
        $scope.isNew = true

        attachmentsToAdd = Immutable.List()
        attachmentsToDelete = Immutable.List()

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

        createAttachments = (obj) ->
            promises = _.map attachmentsToAdd.toJS(), (attachment) ->
                attachmentsService.upload(attachment.file, obj.id, $scope.task.project, 'task')

            return $q.all(promises)

        deleteAttachments = (obj) ->
            promises = _.map attachmentsToDelete.toJS(), (attachment) ->
                return attachmentsService.delete("task", attachment.id)

            return $q.all(promises)

        tagsToAdd = []

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

            itemtags = _.clone($scope.task.tags)

            inserted = _.find itemtags, (it) -> it[0] == value

            if !inserted
                itemtags.push([tag , color])
                $scope.task.tags = itemtags


        $scope.deleteTag = (tag) ->
            value = trim(tag[0].toLowerCase())

            tags = $scope.project.tags
            itemtags = _.clone($scope.task.tags)

            _.remove itemtags, (tag) -> tag[0] == value

            $scope.task.tags = itemtags

            _.pull($scope.task.tags, value)

        $scope.$on "taskform:new", (ctx, sprintId, usId) ->
            $scope.task = $model.make_model('tasks', {
                project: $scope.projectId
                milestone: sprintId
                user_story: usId
                is_archived: false
                status: $scope.project.default_task_status
                assigned_to: null
                tags: [],
                subject: "",
                description: "",
            })
            $scope.isNew = true
            $scope.attachments = Immutable.List()

            resetAttachments()

            # Update texts for creation
            create = $translate.instant("COMMON.CREATE")
            $el.find(".button-green").html(create)

            newTask = $translate.instant("LIGHTBOX.CREATE_EDIT_TASK.TITLE")
            $el.find(".title").html(newTask + "  ")

            $el.find(".tag-input").val("")
            lightboxService.open $el, () ->
                $scope.createEditTaskOpen = false

            $scope.createEditTaskOpen = true

        $scope.$on "taskform:edit", (ctx, task, attachments) ->
            $scope.task = task
            $scope.isNew = false

            $scope.attachments = Immutable.fromJS(attachments)

            resetAttachments()

            # Update texts for edition
            save = $translate.instant("COMMON.SAVE")
            edit = $translate.instant("LIGHTBOX.CREATE_EDIT_TASK.ACTION_EDIT")

            $el.find(".button-green").html(save)
            $el.find(".title").html(edit + "  ")

            $el.find(".tag-input").val("")
            lightboxService.open $el, () ->
                $scope.createEditTaskOpen = false

            $scope.createEditTaskOpen = true


        submitButton = $el.find(".submit-button")

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            params = {
                include_attachments: true,
                include_tasks: true
            }

            if $scope.isNew
                promise = $repo.create("tasks", $scope.task)
                broadcastEvent = "taskform:new:success"
            else
                promise = $repo.save($scope.task)
                broadcastEvent = "taskform:edit:success"

            promise.then (data) ->
                deleteAttachments(data)
                    .then () => createAttachments(data)
                    .then () =>
                        $rs.tasks.getByRef(data.project, data.ref, params).then (task) ->
                            $rootscope.$broadcast(broadcastEvent, task)

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise.then (data) ->
                currentLoading.finish()
                lightboxService.close($el)

        $el.on "submit", "form", submit

        close = () =>
            if !$scope.task.isModified()
                lightboxService.close($el)
                $scope.$apply ->
                    $scope.task.revert()
            else
                $confirm.ask($translate.instant("LIGHTBOX.CREATE_EDIT_TASK.CONFIRM_CLOSE")).then (result) ->
                    lightboxService.close($el)
                    $scope.task.revert()
                    result.finish()

        $el.find('.close').on "click", (event) ->
            event.preventDefault()
            event.stopPropagation()
            close()

        $el.keydown (event) ->
            event.stopPropagation()
            code = if event.keyCode then event.keyCode else event.which
            if code == 27
                close()

        $scope.$on "$destroy", ->
            $el.find('.close').off()
            $el.off()

    return {link: link}


CreateBulkTasksDirective = ($repo, $rs, $rootscope, $loading, lightboxService, $model) ->
    link = ($scope, $el, attrs) ->
        $scope.form = {data: "", usId: null}

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            currentLoading = $loading()
                .target(submitButton)
                .start()

            data = $scope.form.data
            projectId = $scope.projectId
            sprintId = $scope.form.sprintId
            usId = $scope.form.usId

            promise = $rs.tasks.bulkCreate(projectId, sprintId, usId, data)
            promise.then (result) ->
                result =  _.map(result, (x) => $model.make_model('tasks', x))
                currentLoading.finish()
                $rootscope.$broadcast("taskform:bulk:success", result)
                lightboxService.close($el)

            # TODO: error handling
            promise.then null, ->
                currentLoading.finish()
                console.log "FAIL"

        $scope.$on "taskform:bulk", (ctx, sprintId, usId)->
            lightboxService.open($el)
            $scope.form = {data: "", sprintId: sprintId, usId: usId}

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module = angular.module("taigaTaskboard")

module.directive("tgLbCreateEditTask", [
    "$tgRepo",
    "$tgModel",
    "$tgResources",
    "$rootScope",
    "$tgLoading",
    "lightboxService",
    "$translate",
    "$q",
    "$tgConfirm",
    "tgAttachmentsService",
    CreateEditTaskDirective
])

module.directive("tgLbCreateBulkTasks", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "$tgLoading",
    "lightboxService",
    "$tgModel",
    CreateBulkTasksDirective
])
