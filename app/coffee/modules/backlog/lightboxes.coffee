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

CreateEditUserstoryDirective = ($repo, $model, $rs) ->

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
        $ctrl = $el.closest("div.wrapper").controller()
        isNew = true

        $scope.$on "usform:new", ->
            $scope.us = {
                project: $scope.projectId
                is_archived: false
                order: 0
                status: $scope.project.default_us_status
            }
            isNew = true
            editDescription($scope, $el)
            # Update texts for creation
            $el.find(".button-green span").html("Create")
            $el.find(".title").html("New user story  ")
            $el.removeClass("hidden")

        $scope.$on "usform:edit", (ctx, us) ->
            $scope.us = us
            isNew = false
            editDescription($scope, $el)
            # Update texts for edition
            $el.find(".button-green span").html("Save")
            $el.find(".title").html("Edit user story  ")
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
            if isNew
                promise = $repo.create("userstories", $scope.us)
            else
                promise = $repo.save($scope.us)

            promise.then (data) ->
                $el.addClass("hidden")
                $ctrl.loadUserstories()

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

    return {link: link}

CreateBulkUserstroriesDirective = ($repo, $rs, $rootscope) ->
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

            data = $scope.form.data
            projectId = $scope.projectId

            $rs.userstories.bulkCreate(projectId, data).then (result) ->
                $rootscope.$broadcast("usform:bulk:success", result)
                $el.addClass("hidden")

    return {link: link}

module = angular.module("taigaBacklog")
module.directive("tgLbCreateEditUserstory", ["$tgRepo", "$tgModel", "$tgResources", CreateEditUserstoryDirective])
module.directive("tgLbCreateBulkUserstories", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    CreateBulkUserstroriesDirective
])
