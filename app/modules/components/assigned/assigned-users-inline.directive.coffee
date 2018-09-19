###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: components/assigned/assigned-users-inline.directive.coffee
###

AssignedUsersInlineDirective = ($rootscope, $confirm, $repo, $loading, $modelTransform, $template
$translate, $compile, $currentUserService, avatarService, $userListService) ->
    link = ($scope, $el, $attrs, $model) ->
        currentAssignedIds = []
        currentAssignedTo = null

        isAssigned = ->
            return currentAssignedIds.length > 0

        renderUsersList = (text) ->
            users = $userListService.searchUsers(text)

            # Add selected users
            selected = []
            _.map users, (user) ->
                if user.id in currentAssignedIds
                    user.avatar = avatarService.getAvatar(user)
                    selected.push(user)

            # Filter users in searchs
            visible = []
            _.map users, (user) ->
                if user.id not in currentAssignedIds
                    user.avatar = avatarService.getAvatar(user)
                    visible.push(user)

            $scope.selected = _.slice(selected, 0, 5)
            if $scope.selected.length < 5
                $scope.users = _.slice(visible, 0, 5 - $scope.selected.length)
            else
                $scope.users = []
            $scope.showMore = users.length > 5

        renderUsers = () ->
            assignedUsers = _.map(currentAssignedIds, (assignedUserId) -> $scope.usersById[assignedUserId])
            assignedUsers = _.filter assignedUsers, (it) -> return !!it

            $scope.hiddenUsers = if currentAssignedIds.length > 3 then currentAssignedIds.length - 3 else 0
            $scope.assignedUsers = _.slice(assignedUsers, 0, 3)

            $scope.isAssigned = isAssigned()

        applyToModel = () ->
            _.map currentAssignedIds, (userId) ->
                if !$scope.usersById[userId]
                    currentAssignedIds.splice(currentAssignedIds.indexOf(userId), 1)
            if currentAssignedIds.length == 0
                currentAssignedTo = null
            else if currentAssignedIds.indexOf(currentAssignedTo) == -1 || !currentAssignedTo
                currentAssignedTo = currentAssignedIds[0]
            $model.$modelValue.setAttr('assigned_users', currentAssignedIds)
            $model.$modelValue.assigned_to = currentAssignedTo

        $el.on "click", ".users-dropdown", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $scope.usersSearch = ""
            renderUsersList()
            $scope.$apply()
            $el.find(".pop-users").popover().open()

        $scope.selfAssign = () ->
            currentAssignedIds.push($currentUserService.getUser().get('id'))
            renderUsers()
            applyToModel()
            $scope.usersSearch = null

        $scope.unassign = (user) ->
            userIndex = currentAssignedIds.indexOf(user.id)
            currentAssignedIds.splice(userIndex, 1)
            renderUsers()
            applyToModel()

        $el.on "click", ".users-search", (event) ->
            event.stopPropagation()

        $scope.$watch "usersSearch", (searchingText) ->
            if searchingText?
                renderUsersList(searchingText)
                $el.find('input').focus()

        $el.on "click", ".user-list-single", (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            index = currentAssignedIds.indexOf(target.data("user-id"))
            if index == -1
                currentAssignedIds.push(target.data("user-id"))
            else
                currentAssignedIds.splice(index, 1)
            applyToModel()
            renderUsers()
            $el.find(".pop-users").popover().close()
            $scope.usersSearch = null
            $scope.$apply()

        $scope.$watch $attrs.ngModel, (item) ->
            return if not item?
            currentAssignedIds = []
            assigned_to = null

            if item.assigned_users?
                currentAssignedIds = item.assigned_users
            assigned_to = item.assigned_to
            renderUsers()

        $scope.$on "$destroy", ->
            $el.off()

    return {
        scope: true,
        link:link,
        templateUrl: "common/components/assigned-users-inline.html",
        require:"ngModel"
    }

angular.module('taigaComponents').directive("tgAssignedUsersInline", ["$rootScope", "$tgConfirm",
"$tgRepo", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$translate", "$compile",
"tgCurrentUserService", "tgAvatarService", "tgUserListService", AssignedUsersInlineDirective])
