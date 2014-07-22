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

module = angular.module("taigaIssues")

#############################################################################
## Issue Create Lightbox Directive
#############################################################################

CreateIssueDirective = ($repo, $model, $rs, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley()
        $scope.issue = {}

        $scope.$on "issueform:new", ->
            $el.removeClass("hidden")

            $scope.issue = {
                project: $scope.projectId
                subject: ""
                status: $scope.project.default_issue_status
                type: $scope.project.default_issue_type
                priority: $scope.project.default_priority
                severity: $scope.project.default_severity
                estimated_start: null
                estimated_finish: null
            }

        $scope.$on "$destroy", ->
            $el.off()

        submit = ->
            console.log $scope.issue
            if not form.validate()
                return

            promise = $repo.create("issues", $scope.issue)

            promise.then (data) ->
                $el.addClass("hidden")
                console.log "succcess", data
                $rootscope.$broadcast("issueform:new:success", data)

            # FIXME: error handling?
            promise.then null, ->
                console.log "FAIL"

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            submit()

        $el.on "submit", "form", (event) ->
            event.preventDefault()
            submit()

    return {link:link}


module.directive("tgLbCreateIssue", [
    "$tgRepo",
    "$tgModel",
    "$tgResources",
    "$rootScope",
    CreateIssueDirective
])

#############################################################################
## Issue Create Lightbox Directive
#############################################################################

# BulkCreateIssuesDirective = ($repo, $model, $rs, $rootscope) ->
#     link = ($scope, $el, $attrs) ->
#         $scope.$on "issueform:new", ->
#             $el.removeClass("hidden")
#
#         $scope.$on "$destroy", ->
#             $el.off()
#
#         $el.on "click", ".close", (event) ->
#             event.preventDefault()
#             $el.addClass("hidden")
#
#     return {link:link}

# module.directive("tgLbCreateIssue", [
#     "$tgRepo",
#     "$tgModel",
#     "$tgResources",
#     "$rootScope",
#     CreateIssueDirective
# ])

#############################################################################
## Watchers Lightbox directive
#############################################################################

# FIXME: rename to: WatchersLightboxDirective/tgLbWatchers

AddWatcherDirective = ->
    link = ($scope, $el, $attrs) ->
        $scope.usersSearch = {}
        watchers = []

        updateScopeFilteringUsers = () ->
            $scope.filteredUsers = _.difference($scope.users, watchers)

        $scope.$on "watcher:add", ->
            updateScopeFilteringUsers()
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
            watchers.push watcher
            $el.addClass("hidden")
            $scope.$broadcast("watcher:added", watcher)

    return {link:link}

module.directive("tgLbAddWatcher", AddWatcherDirective)

#############################################################################
## AssignedTo Lightbox Directive
#############################################################################

# FIXME: rename to: AssignedToLightboxDirective/tgLbAssignedto

EditAssignedToDirective = ->
    link = ($scope, $el, $attrs) ->
        editingElement = null

        updateScopeFilteringUsers = (searchingText) ->
            console.log "updateScopeFilteringUsers", searchingText
            usersById = _.clone($scope.usersById, false)
            # Exclude selected user
            if $scope.selectedUser?
                delete usersById[$scope.selectedUser.id]

            # Filter text
            usersById = _.filter usersById,  (user) ->
                return _.contains(user.full_name_display.toUpperCase(), searchingText.toUpperCase())

            # Return max of 5 elements
            users = _.map(usersById, (user) -> user)
            $scope.AssignedToUsersSearch = searchingText
            $scope.filteringUsers = users.length > 5
            $scope.filteredUsers = _.first(users, 5)

        $scope.$on "assigned-to:add", (ctx, element) ->
            editingElement = element
            assignedToId = editingElement?.assigned_to

            $scope.selectedUser = null
            $scope.selectedUser = $scope.usersById[assignedToId] if assignedToId?
            updateScopeFilteringUsers("")

            $el.removeClass("hidden")
            $el.find("input").focus()

        $scope.$watch "AssignedToUsersSearch", (searchingText) ->
            updateScopeFilteringUsers(searchingText)

        $el.on "click", ".watcher-single", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            if editingElement?
                user = target.scope().user
                editingElement.assigned_to = user.id

            $el.addClass("hidden")
            $scope.$broadcast("assigned-to:added", editingElement)

        $el.on "click", ".remove-assigned-to", (event) ->
            event.preventDefault()
            event.stopPropagation()

            if editingElement?
                editingElement.assigned_to = null

            $el.addClass("hidden")
            $scope.$broadcast("assigned-to:added", editingElement)

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgLbEditAssignedTo", EditAssignedToDirective)
