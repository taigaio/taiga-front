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

CreateEditUserstoryDirective = ($repo, $model, $rs, $rootScope) ->

    editDescription = ($scope, $el) ->
        $el.find('.markdown-preview a').removeClass("active")
        $el.find('.markdown-preview a.edit').addClass("active")
        descriptionDOM = $el.find("textarea.description")
        descriptionPreviewDOM = $el.find(".description-preview")
        descriptionDOM.show()
        descriptionPreviewDOM.hide()

    previewDescription = ($scope, $el) ->
        $el.find('.markdown-preview a').removeClass("active")
        $el.find('.markdown-preview a.preview').addClass("active")
        descriptionDOM = $el.find("textarea.description")
        descriptionPreviewDOM = $el.find(".description-preview")
        $rs.mdrender.render($scope.projectId, $scope.us.description).then (data) ->
            descriptionDOM.hide()
            descriptionPreviewDOM.html(data.data)
            descriptionPreviewDOM.show()

    link = ($scope, $el, attrs) ->
        isNew = true

        $scope.$on "usform:new", ->
            $scope.us = {
                project: $scope.projectId
                is_archived: false
                status: $scope.project.default_us_status
            }
            isNew = true
            editDescription($scope, $el)
            # Update texts for creation
            $el.find(".button-green span").html("Create") #TODO: i18n
            $el.find(".title").html("New user story  ") #TODO: i18n
            $el.removeClass("hidden")

        $scope.$on "usform:edit", (ctx, us) ->
            $scope.us = us
            isNew = false
            editDescription($scope, $el)
            # Update texts for edition
            $el.find(".button-green span").html("Save") #TODO: i18n
            $el.find(".title").html("Edit user story  ") #TODO: i18n
            $el.removeClass("hidden")

            # Update requirement info (team, client or blocked)
            if us.is_blocked
                $el.find(".blocked-note").show()
                $el.find("label.blocked").addClass("selected")
            if us.team_requirement
                $el.find("label.team-requirement").addClass("selected")
            if us.is_blocked
                $el.find("label.client-requirement").addClass("selected")

        $scope.$on "$destroy", ->
            $el.off()

        # Dom Event Handlers

        $el.on "click", ".markdown-preview a.edit", (event) ->
            event.preventDefault()
            editDescription($scope, $el)

        $el.on "click", ".markdown-preview a.preview", (event) ->
            event.preventDefault()
            previewDescription($scope, $el)

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            if isNew
                promise = $repo.create("userstories", $scope.us)
                broadcastEvent = "usform:new:success"
            else
                promise = $repo.save($scope.us)
                broadcastEvent = "usform:edit:success"

            promise.then (data) ->
                $el.addClass("hidden")
                $rootScope.$broadcast(broadcastEvent, data)

        $el.on "click", "label.blocked", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            target.toggleClass("selected")
            $scope.us.is_blocked = not $scope.us.is_blocked
            $el.find(".blocked-note").toggle(400)

        $el.on "click", "label.team-requirement", (event) ->
            event.preventDefault()
            angular.element(event.currentTarget).toggleClass("selected")
            $scope.us.team_requirement = not $scope.us.team_requirement

        $el.on "click", "label.client-requirement", (event) ->
            event.preventDefault()
            angular.element(event.currentTarget).toggleClass("selected")
            $scope.us.client_requirement = not $scope.us.client_requirement

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

CreateBulkUserstoriesDirective = ($repo, $rs, $rootscope) ->
    link = ($scope, $el, attrs) ->
        $scope.form = {data: ""}

        $scope.$on "usform:bulk", ->
            $el.removeClass("hidden")
            $scope.form = {data: ""}

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            data = $scope.form.data
            projectId = $scope.projectId

            $rs.userstories.bulkCreate(projectId, data).then (result) ->
                $rootscope.$broadcast("usform:bulk:success", result)
                $el.addClass("hidden")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

CreateSprint = ($repo, $rs, $rootscope) ->
    link = ($scope, $el, attrs) ->
        submit = ->
            form = $el.find("form").checksley()
            if not form.validate()
                return

            promise = $repo.create("milestones", $scope.sprint)
            promise.then (data) ->
                $el.addClass("hidden")
                $rootscope.$broadcast("sprintform:create:success", data)

            promise.then null, (data) ->
                form.setErrors(data)

        $scope.$on "sprintform:create", ->
            $el.removeClass("hidden")
            $scope.sprint = {
                project: $scope.projectId
                name: null
                estimated_start: null
                estimated_finish: null
            }

            lastSprintNameDom = $el.find(".last-sprint-name")
            sprintName = $scope.sprints?[0].name
            if sprintName?
                lastSprintNameDom.text(" last sprint is <strong> #{sprintName} ;-) </strong>")

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            submit()

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module = angular.module("taigaBacklog")
module.directive("tgLbCreateEditUserstory", ["$tgRepo", "$tgModel", "$tgResources", "$rootScope",
                                             CreateEditUserstoryDirective])
module.directive("tgLbCreateBulkUserstories", ["$tgRepo", "$tgResources", "$rootScope",
                                               CreateBulkUserstoriesDirective])
module.directive("tgLbCreateSprint", ["$tgRepo", "$tgResources", "$rootScope", CreateSprint])
