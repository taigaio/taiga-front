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
# File: modules/taskboard/lightboxes.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce

CreateEditTaskDirective = ($repo, $model, $rs, $rootscope, lightboxService) ->
    link = ($scope, $el, attrs) ->
        $scope.isNew = true

        $scope.$on "taskform:new", (ctx, sprintId, usId) ->
            $scope.task = {
                project: $scope.projectId
                milestone: sprintId
                user_story: usId
                is_archived: false
                status: $scope.project.default_task_status
                assigned_to: null
                tags: []
            }
            $scope.isNew = true

            # Update texts for creation
            $el.find(".button-green span").html("Create") #TODO: i18n
            $el.find(".title").html("New task  ") #TODO: i18n
            lightboxService.open($el)

        $scope.$on "taskform:edit", (ctx, task) ->
            $scope.task = task
            $scope.isNew = false

            # Update texts for edition
            $el.find(".button-green span").html("Save") #TODO: i18n
            $el.find(".title").html("Edit task  ") #TODO: i18n
            lightboxService.open($el)

        $el.on "click", ".button-green", debounce 2000, (event) ->
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            if $scope.isNew
                promise = $repo.create("tasks", $scope.task)
                broadcastEvent = "taskform:new:success"
            else
                promise = $repo.save($scope.task)
                broadcastEvent = "taskform:edit:success"

            # FIXME: error handling?
            promise.then (data) ->
                lightboxService.close($el)
                $rootscope.$broadcast(broadcastEvent, data)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


CreateBulkTasksDirective = ($repo, $rs, $rootscope, lightboxService) ->
    link = ($scope, $el, attrs) ->
        $scope.form = {data: "", usId: null}

        $scope.$on "taskform:bulk", (ctx, sprintId, usId)->
            lightboxService.open($el)
            $scope.form = {data: "", sprintId: sprintId, usId: usId}

        $el.on "click", ".button-green", debounce 2000, (event) ->
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            data = $scope.form.data
            projectId = $scope.projectId
            sprintId = $scope.form.sprintId
            usId = $scope.form.usId

            promise = $rs.tasks.bulkCreate(projectId, sprintId, usId, data)
            promise.then (result) ->
                $rootscope.$broadcast("taskform:bulk:success", result)
                lightboxService.close($el)

            # TODO: error handling
            promise.then null, ->
                console.log "FAIL"

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module = angular.module("taigaTaskboard")

module.directive("tgLbCreateEditTask", [
    "$tgRepo",
    "$tgModel",
    "$tgResources",
    "$rootScope",
    "lightboxService",
    CreateEditTaskDirective
])

module.directive("tgLbCreateBulkTasks", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "lightboxService",
    CreateBulkTasksDirective
])
