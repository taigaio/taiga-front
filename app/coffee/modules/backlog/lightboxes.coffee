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

CreateEditSprint = ($repo, $confirm, $rs, $rootscope, lightboxService, $loading) ->
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
            form = $el.find("form").checksley()

            if not form.validate()
                hasErrors = true
                $el.find(".last-sprint-name").addClass("disappear")
                return

            hasErrors = false
            newSprint = angular.copy($scope.sprint)
            broadcastEvent = null

            if createSprint
                newSprint.estimated_start = moment(newSprint.estimated_start).format("YYYY-MM-DD")
                newSprint.estimated_finish = moment(newSprint.estimated_finish).format("YYYY-MM-DD")
                promise = $repo.create("milestones", newSprint)
                broadcastEvent = "sprintform:create:success"
            else
                newSprint.setAttr("estimated_start", moment(newSprint.estimated_start).format("YYYY-MM-DD"))
                newSprint.setAttr("estimated_finish", moment(newSprint.estimated_finish).format("YYYY-MM-DD"))
                promise = $repo.save(newSprint)
                broadcastEvent = "sprintform:edit:success"

            $loading.start(submitButton)

            promise.then (data) ->
                $loading.finish(submitButton)
                $scope.sprintsCounter += 1 if createSprint
                $rootscope.$broadcast(broadcastEvent, data)

                lightboxService.close($el)

            promise.then null, (data) ->
                $loading.finish(submitButton)

                form.setErrors(data)
                if data._error_message
                    $confirm.notify("light-error", data._error_message)
                else if data.__all__
                    $confirm.notify("light-error", data.__all__[0])

        remove = ->
            #TODO: i18n
            title = "Delete sprint"
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

        $scope.$on "sprintform:create", (event, projectId) ->
            createSprint = true
            $scope.sprint.project = projectId
            $scope.sprint.name = null
            $scope.sprint.slug = null

            lastSprint = $scope.sprints[0]

            estimatedStart = moment()
            if $scope.sprint.estimated_start
                estimatedStart = moment($scope.sprint.estimated_start)
            else if lastSprint?
                estimatedStart = moment(lastSprint.estimated_finish)
            $scope.sprint.estimated_start = estimatedStart.format("DD MMM YYYY")

            estimatedFinish = moment().add(2, "weeks")
            if $scope.sprint.estimated_finish
                estimatedFinish = moment($scope.sprint.estimated_finish)
            else if lastSprint?
                estimatedFinish = moment(lastSprint.estimated_finish).add(2, "weeks")
            $scope.sprint.estimated_finish = estimatedFinish.format("DD MMM YYYY")

            lastSprintNameDom = $el.find(".last-sprint-name")
            if lastSprint?.name?
                lastSprintNameDom.html(" last sprint is <strong> #{lastSprint.name} ;-) </strong>")

            $el.find(".delete-sprint").addClass("hidden")
            $el.find(".title").text("New sprint") #TODO i18n
            $el.find(".button-green").text("Create") #TODO i18n
            lightboxService.open($el)
            $el.find(".sprint-name").focus()

        $scope.$on "sprintform:edit", (ctx, sprint) ->
            createSprint = false
            $scope.$apply ->
                $scope.sprint = sprint
                $scope.sprint.estimated_start = moment($scope.sprint.estimated_start).format("DD MMM YYYY")
                $scope.sprint.estimated_finish = moment($scope.sprint.estimated_finish).format("DD MMM YYYY")

            $el.find(".delete-sprint").removeClass("hidden")
            $el.find(".title").text("Edit sprint") #TODO i18n
            $el.find(".button-green").text("Save") #TODO i18n
            lightboxService.open($el)
            $el.find(".sprint-name").focus().select()
            $el.find(".last-sprint-name").addClass("disappear")

        $el.on "keyup", ".sprint-name", (event) ->
            if $el.find(".sprint-name").val().length > 0 or hasErrors
                $el.find(".last-sprint-name").addClass("disappear")
            else
                $el.find(".last-sprint-name").removeClass("disappear")

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit
        $el.on "click", ".submit-button", submit

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
    "$tgLoading"
    CreateEditSprint
])
