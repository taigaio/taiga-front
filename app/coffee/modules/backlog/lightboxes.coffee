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
# File: modules/backlog/lightboxes.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce

module = angular.module("taigaBacklog")

#############################################################################
## Creare/Edit Sprint Lightbox Directive
#############################################################################

CreateEditSprint = ($repo, $confirm, $rs, $rootscope, lightboxService, $loading, $translate) ->
    link = ($scope, $el, attrs) ->
        hasErrors = false
        createSprint = true

        $scope.sprint = {
            project: null
            name: null
            estimated_start: null
            estimated_finish: null
        }

        submit = debounce 2000, (event) =>
            event.preventDefault()
            target = angular.element(event.currentTarget)
            prettyDate = $translate.instant("COMMON.PICKERDATE.FORMAT")

            submitButton = $el.find(".submit-button")
            form = $el.find("form").checksley()

            if not form.validate()
                hasErrors = true
                $el.find(".last-sprint-name").addClass("disappear")
                return

            hasErrors = false
            newSprint = angular.copy($scope.sprint)
            broadcastEvent = null

            if createSprint
                newSprint.estimated_start = moment(newSprint.estimated_start, prettyDate).format("YYYY-MM-DD")
                newSprint.estimated_finish = moment(newSprint.estimated_finish,prettyDate).format("YYYY-MM-DD")
                promise = $repo.create("milestones", newSprint)
                broadcastEvent = "sprintform:create:success"
            else
                newSprint.setAttr("estimated_start",
                                  moment(newSprint.estimated_start, prettyDate).format("YYYY-MM-DD"))
                newSprint.setAttr("estimated_finish",
                                  moment(newSprint.estimated_finish, prettyDate).format("YYYY-MM-DD"))
                promise = $repo.save(newSprint)
                broadcastEvent = "sprintform:edit:success"

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise.then (data) ->
                currentLoading.finish()
                $scope.sprintsCounter += 1 if createSprint
                $rootscope.$broadcast(broadcastEvent, data)

                lightboxService.close($el)

            promise.then null, (data) ->
                currentLoading.finish()

                form.setErrors(data)
                if data._error_message
                    $confirm.notify("light-error", data._error_message)
                else if data.__all__
                    $confirm.notify("light-error", data.__all__[0])

        remove = ->
            title = $translate.instant("LIGHTBOX.DELETE_SPRINT.TITLE")
            message = $scope.sprint.name

            $confirm.askOnDelete(title, message).then (finish) =>
                onSuccess = ->
                    finish()
                    $scope.milestonesCounter -= 1
                    lightboxService.close($el)
                    $rootscope.$broadcast("sprintform:remove:success")

                onError = ->
                    finish(false)
                    $confirm.notify("error")
                $repo.remove($scope.sprint).then(onSuccess, onError)

        getLastSprint = ->
            openSprints = _.filter $scope.sprints, (sprint) ->
                return !sprint.closed

            sortedSprints = _.sortBy openSprints, (sprint) ->
                return moment(sprint.estimated_finish, 'YYYY-MM-DD').format('X')

            return sortedSprints[sortedSprints.length - 1]

        $scope.$on "sprintform:create", (event, projectId) ->
            form = $el.find("form").checksley()
            form.reset()

            createSprint = true
            prettyDate = $translate.instant("COMMON.PICKERDATE.FORMAT")
            $scope.sprint.project = projectId
            $scope.sprint.name = null
            $scope.sprint.slug = null

            lastSprint = getLastSprint()

            estimatedStart = moment()

            if lastSprint
                estimatedStart = moment(lastSprint.estimated_finish)
            else if $scope.sprint.estimated_start
                estimatedStart = moment($scope.sprint.estimated_start)

            $scope.sprint.estimated_start = estimatedStart.format(prettyDate)

            estimatedFinish = moment().add(2, "weeks")

            if lastSprint
                estimatedFinish = moment(lastSprint.estimated_finish).add(2, "weeks")
            else if $scope.sprint.estimated_finish
                estimatedFinish = moment($scope.sprint.estimated_finish)

            $scope.sprint.estimated_finish = estimatedFinish.format(prettyDate)

            lastSprintNameDom = $el.find(".last-sprint-name")
            if lastSprint?.name?
                text = $translate.instant("LIGHTBOX.ADD_EDIT_SPRINT.LAST_SPRINT_NAME", {
                            lastSprint: lastSprint.name})
                lastSprintNameDom.html(text)

            $el.find(".delete-sprint").addClass("hidden")

            text = $translate.instant("LIGHTBOX.ADD_EDIT_SPRINT.TITLE")
            $el.find(".title").text(text)

            text = $translate.instant("COMMON.CREATE")
            $el.find(".button-green").text(text)

            lightboxService.open($el)
            $el.find(".sprint-name").focus()
            $el.find(".last-sprint-name").removeClass("disappear")

        $scope.$on "sprintform:edit", (ctx, sprint) ->
            createSprint = false
            prettyDate = $translate.instant("COMMON.PICKERDATE.FORMAT")

            $scope.$apply ->
                $scope.sprint = sprint
                $scope.sprint.estimated_start = moment($scope.sprint.estimated_start).format(prettyDate)
                $scope.sprint.estimated_finish = moment($scope.sprint.estimated_finish).format(prettyDate)

            $el.find(".delete-sprint").removeClass("hidden")

            editSprint = $translate.instant("BACKLOG.EDIT_SPRINT")
            $el.find(".title").text(editSprint)

            save = $translate.instant("COMMON.SAVE")
            $el.find(".button-green").text(save)

            lightboxService.open($el)
            $el.find(".sprint-name").focus().select()
            $el.find(".last-sprint-name").addClass("disappear")

        $el.on "keyup", ".sprint-name", (event) ->
            if $el.find(".sprint-name").val().length > 0 or hasErrors
                $el.find(".last-sprint-name").addClass("disappear")
            else
                $el.find(".last-sprint-name").removeClass("disappear")

        $el.on "submit", "form", submit

        $el.on "click", ".delete-sprint .icon-delete", (event) ->
            event.preventDefault()
            remove()

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgLbCreateEditSprint", [
    "$tgRepo",
    "$tgConfirm",
    "$tgResources",
    "$rootScope",
    "lightboxService"
    "$tgLoading",
    "$translate",
    CreateEditSprint
])
