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
# File: modules/issues/lightboxes.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce

CreateIssueDirective = ($repo, $model, $rs, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        $scope.$on "issueform:new", ->
            $el.removeClass("hidden")

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

    return {link:link}


module = angular.module("taigaIssues")
module.directive("tgLbCreateIssue", [
    "$tgRepo",
    "$tgModel",
    "$tgResources",
    "$rootScope",
    CreateIssueDirective
])

AddWatcherDirective = () ->
    link = ($scope, $el, $attrs) ->
        $scope.usersSearch = {}
        $scope.$on "watcher:add", ->
            $el.removeClass("hidden")
            $scope.$apply ->
                $scope.usersSearch = {}

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".watcher-single", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            watcher = target.scope().user
            $el.addClass("hidden")
            $scope.$broadcast("watcher:added", watcher)

    return {link:link}

module.directive("tgLbAddWatcher", AddWatcherDirective)


EditAssignedToDirective = () ->
    link = ($scope, $el, $attrs) ->
        $scope.usersSearch = {}
        editingElement = null

        $scope.$on "assigned-to:add", (ctx, element) ->
            editingElement = element
            $el.removeClass("hidden")
            $el.find("input").focus()
            $scope.usersSearch = {}

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".watcher-single", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            if editingElement?
                editingElement.assigned_to = target.scope().user.id

            $el.addClass("hidden")
            $scope.$broadcast("assigned-to:added", editingElement)

    return {link:link}

module.directive("tgLbEditAssignedTo", EditAssignedToDirective)
