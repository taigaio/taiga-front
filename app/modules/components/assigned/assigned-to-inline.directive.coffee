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
# File: components/assigned/assigned-to-inline.directive.coffee
###

AssignedToInlineDirective = ($rootscope, $confirm, $repo, $loading, $modelTransform, $template
$translate, $compile, $currentUserService, avatarService, $userListService) ->
    link = ($scope, $el, $attr, $model) ->
        isEditable = ->
            return $scope.project?.my_permissions?.indexOf($attr.requiredPerm) != -1

        renderUserList = (text) ->
            selectedId = $model.$modelValue.assigned_to
            users = $userListService.searchUsers(text)
            users = _.reject(users, {"id": selectedId}) if selectedId

            visibleUsers = _.slice(users, 0, 5)
            visibleUsers = _.map visibleUsers, (user) -> user.avatar = avatarService.getAvatar(user)

            $scope.users = _.slice(users, 0, 5)
            $scope.showMore = users.length > 5

        renderUser = (assignedObject) ->
            if assignedObject?.assigned_to
                $scope.selected = assignedObject.assigned_to
                assigned_to_extra_info = $scope.usersById[$scope.selected]
                $scope.fullName = assigned_to_extra_info?.full_name_display
                $scope.isUnassigned = false
                $scope.avatar = avatarService.getAvatar(assigned_to_extra_info)
                $scope.bg = $scope.avatar.bg
                $scope.isIocaine = assignedObject?.is_iocaine
            else
                $scope.fullName = $translate.instant("COMMON.ASSIGNED_TO.ASSIGN")
                $scope.isUnassigned = true
                $scope.avatar = avatarService.getAvatar(null)
                $scope.bg = null
                $scope.isIocaine = false

            $scope.fullNameVisible = !($scope.isUnassigned && !$currentUserService.isAuthenticated())
            $scope.isEditable = isEditable()

        $el.on "click", ".users-search", (event) ->
            event.stopPropagation()

        $el.on "click", ".users-dropdown", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $scope.usersSearch = ""
            renderUserList()
            $scope.$apply()
            $el.find(".pop-users").popover().open()

        $scope.selfAssign = () ->
            $model.$modelValue.assigned_to = $currentUserService.getUser().get('id')
            renderUser($model.$modelValue)

        $scope.unassign = () ->
            $model.$modelValue.assigned_to  = null
            renderUser()

        $scope.$watch "usersSearch", (searchingText) ->
            if searchingText?
                renderUserList(searchingText)
                $el.find('input').focus()

        $el.on "click", ".user-list-single", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            $model.$modelValue.assigned_to = target.data("user-id")
            renderUser($model.$modelValue)
            $scope.$apply()

        $scope.$watch $attr.ngModel, (instance) ->
            renderUser(instance)

        $scope.$on "isiocaine:changed", (ctx, instance) ->
            renderUser(instance)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link,
        templateUrl: "common/components/assigned-to-inline.html"
        require:"ngModel"
    }

angular.module('taigaComponents').directive("tgAssignedToInline", ["$rootScope", "$tgConfirm",
"$tgRepo", "$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$translate", "$compile",
"tgCurrentUserService", "tgAvatarService", "tgUserListService", AssignedToInlineDirective])
