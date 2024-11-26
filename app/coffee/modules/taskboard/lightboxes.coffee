###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce
trim = @.taiga.trim


module = angular.module("taigaTaskboard")


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

        $scope.$on "taskform:bulk", (ctx, sprintId, usId)->
            lightboxService.open($el)
            $scope.form = {data: "", sprintId: sprintId, usId: usId}

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgLbCreateBulkTasks", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "$tgLoading",
    "lightboxService",
    "$tgModel",
    CreateBulkTasksDirective
])
