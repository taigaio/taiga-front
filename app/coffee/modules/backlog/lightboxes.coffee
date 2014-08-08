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

module = angular.module("taigaBacklog")

#############################################################################
## Creare/Edit Sprint Lightbox Directive
#############################################################################

CreateEditSprint = ($repo, $confirm, $rs, $rootscope, lightboxService) ->
    link = ($scope, $el, attrs) ->
        createSprint = true

        # FIXME: form should be initialized once and used in
        # each submit...
        submit = ->
            form = $el.find("form").checksley()
            if not form.validate()
                return

            if createSprint
                promise = $repo.create("milestones", $scope.sprint)
            else
                promise = $repo.save($scope.sprint)

            promise.then (data) ->
                $scope.sprintsCounter += 1 if createSprint
                lightboxService.close($el)
                $rootscope.$broadcast("sprintform:create:success", data)

            promise.then null, (data) ->
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        remove = ->
            #TODO: i18n
            title = "Delete sprint"
            subtitle = $scope.sprint.name

            $confirm.ask(title, subtitle).then =>
                onSuccess = ->
                    $scope.milestonesCounter -= 1
                    lightboxService.close($el)
                    $rootscope.$broadcast("sprintform:remove:success")
                onError = ->
                    $confirm.notify("error")
                $repo.remove($scope.sprint).then(onSuccess, onError)

        $scope.$on "sprintform:create", (event, projectId) ->
            createSprint = true
            $scope.sprint = {
                project: projectId
                name: null
                estimated_start: null
                estimated_finish: null
            }

            lastSprintNameDom = $el.find(".last-sprint-name")
            sprintName = $scope.sprints?[0].name
            if sprintName?
                lastSprintNameDom.html(" last sprint is <strong> #{sprintName} ;-) </strong>")

            $el.find(".delete-sprint").hide()
            $el.find(".title").text("New sprint") #TODO i18n
            $el.find(".button-green").text("Create") #TODO i18n
            lightboxService.open($el)

        $scope.$on "sprintform:edit", (ctx, sprint) ->
            createSprint = false
            $scope.$apply ->
                $scope.sprint = sprint

            $el.find(".delete-sprint").show()
            $el.find(".title").text("Edit sprint") #TODO i18n
            $el.find(".button-green").text("Save") #TODO i18n
            lightboxService.open($el)

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            submit()

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
    CreateEditSprint
])
