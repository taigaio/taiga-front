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
# File: components/assigned/assigned-users.directive.coffee
###

AssignedUsersDirective = ($rootscope, $confirm, $repo, $modelTransform, $template, $compile,
$translate, $currentUserService) ->
    # You have to include a div with the tg-lb-assignedusers directive in the page
    # where use this directive

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project?.my_permissions?.indexOf($attrs.requiredPerm) != -1
        isAssigned = ->
            return $scope.assignedUsers.length > 0

        save = (assignedUsers, assignedToUser) ->
            transform = $modelTransform.save (item) ->
                item.assigned_users = assignedUsers
                if not item.assigned_to
                    item.assigned_to = assignedToUser
                return item

            transform.then ->
                assignedUsers = _.map(assignedUsers, (assignedUserId) -> $scope.usersById[assignedUserId])
                renderAssignedUsers(assignedUsers)
                result = $rootscope.$broadcast("object:updated")

            transform.then null, ->
                $confirm.notify("error")

        openAssignedUsers = ->
            item = _.clone($model.$modelValue, false)
            $rootscope.$broadcast("assigned-user:add", item)

        $scope.selfAssign = () ->
            return if not isEditable()
            currentUserId = $currentUserService.getUser().get('id')
            assignedUsers = _.clone($model.$modelValue.assigned_users, false)
            assignedUsers.push(currentUserId)
            assignedUsers = _.uniq(assignedUsers)
            save(assignedUsers, currentUserId)

        $scope.unassign = (user) ->
            return if not isEditable()
            assignedUserId = user.id

            title = $translate.instant("COMMON.ASSIGNED_USERS.TITLE_LIGHTBOX_DELETE_ASSIGNED")
            message = $scope.usersById[assignedUserId].full_name_display

            $confirm.askOnDelete(title, message).then (askResponse) ->
                askResponse.finish()

                assignedUserIds = _.clone($model.$modelValue.assigned_users, false)
                assignedUserIds = _.pull(assignedUserIds, assignedUserId)

                deleteAssignedUser(assignedUserIds)

        deleteAssignedUser = (assignedUserIds) ->
            transform = $modelTransform.save (item) ->
                item.assigned_users = assignedUserIds

                # Update as
                if item.assigned_to not in assignedUserIds and assignedUserIds.length > 0
                    item.assigned_to = assignedUserIds[0]
                if assignedUserIds.length == 0
                    item.assigned_to = null

                return item

            transform.then () ->
                item = $modelTransform.getObj()
                assignedUsers = _.map(item.assignedUsers, (assignedUserId) -> $scope.usersById[assignedUserId])
                renderAssignedUsers(assignedUsers)
                $rootscope.$broadcast("object:updated")

            transform.then null, ->
                item.revert()
                $confirm.notify("error")

        renderAssignedUsers = (assignedUsers) ->
            $scope.assignedUsers = assignedUsers
            $scope.isEditable = isEditable()
            $scope.isAssigned = isAssigned()
            $scope.openAssignedUsers = openAssignedUsers

        $scope.$on "assigned-user:deleted", (ctx, assignedUserId) ->
            assignedUsersIds = _.clone($model.$modelValue.assigned_users, false)
            assignedUsersIds = _.pull(assignedUsersIds, assignedUserId)
            assignedUsersIds = _.uniq(assignedUsersIds)
            deleteAssignedUser(assignedUsersIds)

        $scope.$on "assigned-user:added", (ctx, assignedUserId) ->
            assignedUsers = _.clone($model.$modelValue.assigned_users, false)
            assignedUsers.push(assignedUserId)
            assignedUsers = _.uniq(assignedUsers)

            # Save assigned_users and assignedUserId for assign_to legacy attribute
            save(assignedUsers, assignedUserId)

        $scope.$watch $attrs.ngModel, (item) ->
            return if not item?
            assignedUsers = _.map(item.assigned_users, (assignedUserId) -> $scope.usersById[assignedUserId])
            assignedUsers = _.filter assignedUsers, (it) -> return !!it

            renderAssignedUsers(assignedUsers)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        scope: true,
        templateUrl: "common/components/assigned-users.html",
        link:link
        require:"ngModel"
    }

angular.module('taigaComponents').directive("tgAssignedUsers", ["$rootScope", "$tgConfirm",
"$tgRepo", "$tgQueueModelTransformation", "$tgTemplate", "$compile", "$translate",
"tgCurrentUserService", AssignedUsersDirective])
