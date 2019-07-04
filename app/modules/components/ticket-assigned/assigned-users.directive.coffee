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
$translate, $currentUserService, $lightboxFactory) ->
    link = ($scope, $el, $attrs, $model) ->
        currentUserId = $currentUserService.getUser().get('id')
        $scope.visibleAssignedUsersCount = 4
        $scope.displayHidden = false

        $scope.toggleFold = () ->
            $scope.displayHidden = !$scope.displayHidden

        isEditable = ->
            return $scope.project?.my_permissions?.indexOf($attrs.requiredPerm) != -1

        save = (assignedUsersIds, assignedToUser) ->
            $scope.loading = true
            transform = $modelTransform.save (item) ->
                item.assigned_users = assignedUsersIds
                if assignedToUser
                    item.assigned_to = assignedToUser
                else if not assignedUsersIds.length
                    item.assigned_to = null
                else if not _.includes(assignedUsersIds, item.assigned_to)
                    item.assigned_to = assignedUsersIds[0]
                return item

            transform.then ->
                result = $rootscope.$broadcast("object:updated")
            transform.then null, ->
                $confirm.notify("error")
            transform.finally ->
                $scope.loading = false

        $scope.openAssignedUsers = () ->
            onClose = (assignedUsers) =>
                save(assignedUsers)

            item = _.clone($model.$modelValue, false)
            $lightboxFactory.create(
                'tg-lb-select-user',
                {
                    "class": "lightbox lightbox-select-user",
                },
                {
                    "currentUsers": item.assigned_users,
                    "activeUsers": $scope.activeUsers,
                    "onClose": onClose,
                    "lbTitle": $translate.instant("COMMON.ASSIGNED_USERS.ADD"),
                }
            )

        $el.on "click", ".user-list-single", (event) ->
            return if not isEditable()
            event.stopPropagation()
            $scope.openAssignedUsers()

        $el.on "click", ".remove-user", (event) ->
            return if not isEditable()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            assignedUserId = target.data("user-id")

            title = $translate.instant("COMMON.ASSIGNED_USERS.TITLE_LIGHTBOX_DELETE_ASSIGNED")
            message = $scope.usersById[assignedUserId].full_name_display

            $confirm.askOnDelete(title, message).then (askResponse) ->
                askResponse.finish()

                assignedUserIds = _.clone($model.$modelValue.assigned_users, false)
                assignedUserIds = _.pull(assignedUserIds, assignedUserId)

                deleteAssignedUser(assignedUserIds)

        $scope.selfAssign = () ->
            return if not isEditable()
            assignedUsers = _.clone($model.$modelValue.assigned_users, false)
            assignedUsers.push(currentUserId)
            assignedUsers = _.uniq(assignedUsers)
            save(assignedUsers, currentUserId)

        deleteAssignedUser = (assignedUserIds) ->
            $scope.loading = true
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
                $attrs.ngModel = item
                $rootscope.$broadcast("object:updated")
            transform.then null, ->
                item.revert()
                $confirm.notify("error")
            transform.finally ->
                $scope.loading = false

        render = (assignedUserIds) ->
            assignedUsers = _.map(assignedUserIds, (assignedUserId) -> $scope.usersById[assignedUserId])
            $scope.assignedUsers = _.compact(assignedUsers)
            $scope.selfAssigned = _.includes(assignedUserIds, currentUserId)
            $scope.isEditable = isEditable()

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

        $scope.$watch $attrs.ngModel, (item, currentItem) ->
            return if not item?
            render(item.assigned_users)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        scope: true,
        templateUrl: "components/ticket-assigned/assigned-users.html",
        link:link
        require:"ngModel"
    }

angular.module('taigaComponents').directive("tgAssignedUsers", ["$rootScope", "$tgConfirm",
"$tgRepo", "$tgQueueModelTransformation", "$tgTemplate", "$compile", "$translate",
"tgCurrentUserService", "tgLightboxFactory", AssignedUsersDirective])
