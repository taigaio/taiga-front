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

CreateEditUserstoryDirective = ($repo, $model) ->
    link = ($scope, $el, attrs) ->
        $scope.us = {}
        # TODO: defaults
        $scope.$on "usform:new", ->
            $scope.us = {}
            $el.removeClass("hidden")

        $scope.$on "usform:edit", (ctx, us) ->
            $el.removeClass("hidden")
            $scope.us = us

        $scope.$on "$destroy", ->
            $el.off()

        # Dom Event Handlers
        $el.on "click", ".markdown-preview a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            target.parent().find("a").removeClass("active")
            target.addClass("active")

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            console.log $scope.us

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
module.directive("tgLbCreateEditUserstory", ["$tgRepo", "$tgModel", CreateEditUserstoryDirective])
module.directive("tgLbCreateBulkUserstories", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    CreateBulkUserstroriesDirective
])


