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

CreateEditSprint = ($repo, $confirm, $rs, $rootscope, lightboxService, $loading) ->
    link = ($scope, $el, attrs) ->
        createSprint = true
        $scope.sprint = {
            project: null
            name: null
            estimated_start: null
            estimated_finish: null
        }

        submit = (event) ->
            form = $el.find("form").checksley()
            if not form.validate()
                return

            newSprint = angular.copy($scope.sprint)

            if createSprint
                newSprint.estimated_start = moment(newSprint.estimated_start).format("YYYY-MM-DD")
                newSprint.estimated_finish = moment(newSprint.estimated_finish).format("YYYY-MM-DD")
                promise = $repo.create("milestones", newSprint)

            else
                newSprint.setAttr("estimated_start", moment(newSprint.estimated_start).format("YYYY-MM-DD"))
                newSprint.setAttr("estimated_finish", moment(newSprint.estimated_finish).format("YYYY-MM-DD"))
                promise = $repo.save(newSprint)

            target = angular.element(event.currentTarget)
            $loading.start(target)

            promise.then (data) ->
                $loading.finish(target)
                $scope.sprintsCounter += 1 if createSprint
                lightboxService.close($el)
                $rootscope.$broadcast("sprintform:create:success", data)

            promise.then null, (data) ->
                $loading.finish(target)
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
            $scope.sprint.project = projectId
            $scope.sprint.name = null
            $scope.sprint.slug = null
            $scope.sprint.estimated_start = moment($scope.sprint.estimated_start).format("DD MMM YYYY")
            $scope.sprint.estimated_finish = moment($scope.sprint.estimated_finish).format("DD MMM YYYY")

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
                $scope.sprint.estimated_start = moment($scope.sprint.estimated_start).format("DD MMM YYYY")
                $scope.sprint.estimated_finish = moment($scope.sprint.estimated_finish).format("DD MMM YYYY")

            $el.find(".delete-sprint").show()
            $el.find(".title").text("Edit sprint") #TODO i18n
            $el.find(".button-green").text("Save") #TODO i18n
            lightboxService.open($el)

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            submit(event)

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
