###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

            if (!$model.$modelValue.assigned_users)
                $model.$modelValue.assigned_users = currentAssignedIds
            else
                $model.$modelValue.setAttr('assigned_users', currentAssignedIds)
            $model.$modelValue.assigned_to = currentAssignedTo

        $el.on "click", ".users-dropdown", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $scope.usersSearch = null
            renderUsersList()
            $scope.$apply()
            $el.find(".pop-users").popover().open()

        $scope.assign = (user) ->
            currentAssignedIds.push(user.id)
            renderUsers()
            applyToModel()

        $scope.selfAssign = () ->
            currentAssignedIds.push($currentUserService.getUser().get('id'))
            renderUsers()
            applyToModel()

        $scope.unassign = (user) ->
            index = currentAssignedIds.indexOf(user.id)
            currentAssignedIds.splice(index, 1)
            renderUsers()
            applyToModel()

        $el.on "click", ".users-search", (event) ->
            event.stopPropagation()

        $scope.$watch "usersSearch", (searchingText) ->
            if searchingText?
                renderUsersList(searchingText)
                $el.find('input').focus()

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
        templateUrl: "components/assigned-inline/assigned-users-inline.html",
        require:"ngModel"
    }

angular.module('taigaComponents').directive("tgAssignedUsersInline", ["$rootScope", "$tgConfirm",
"$tgRepo", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$translate", "$compile",
"tgCurrentUserService", "tgAvatarService", "tgUserListService", AssignedUsersInlineDirective])
