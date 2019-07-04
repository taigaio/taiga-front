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
# File: components/assigned/assigned-to.directive.coffee
###

AssignedToDirective = ($rootscope, $confirm, $repo, $loading, $modelTransform, $template,
$translate, $compile, $currentUserService, avatarService, $lightboxFactory) ->
    link = ($scope, $el, $attrs, $model) ->
        currentUserId = $currentUserService.getUser()?.get('id')

        isEditable = ->
            return $scope.project?.my_permissions?.indexOf($attrs.requiredPerm) != -1

        isIocaine = (item) ->
            return item?.is_iocaine

        isSelfAssigned = ->
            return $scope.assignedUser && $scope.assignedUser.id == currentUserId

        save = (userId) ->
            $scope.loading = true
            transform = $modelTransform.save (item) ->
                item.assigned_to = userId
                return item

            transform.then (item) ->
                $attrs.ngModel = item
                $rootscope.$broadcast("object:updated")

            transform.then null, ->
                $confirm.notify("error")

            transform.finally () ->
                $scope.loading = false

            return transform

        render = (item) ->
            $scope.assignedUser = $scope.usersById[item?.assigned_to]
            $scope.isEditable = isEditable()
            $scope.isIocaine = isIocaine(item)
            $scope.isSelfAssigned = isSelfAssigned()

        $el.on "click", ".remove-user", (event) ->
            return if not isEditable()
            event.stopPropagation()
            title = $translate.instant("COMMON.ASSIGNED_TO.CONFIRM_UNASSIGNED")
            $confirm.ask(title).then (response) ->
                response.finish()
                save(null)

        $scope.openAssignedUsers = () ->
            onClose = (assignedUsers) =>
                save(assignedUsers.pop() || null)

            item = _.clone($model.$modelValue, false)
            $lightboxFactory.create(
                'tg-lb-select-user',
                {
                    "class": "lightbox lightbox-select-user",
                },
                {
                    "currentUsers": [item.assigned_to],
                    "activeUsers": @.activeUsers,
                    "onClose": onClose,
                    "single": true,
                    "lbTitle": $translate.instant("COMMON.ASSIGNED_USERS.ADD"),
                }
            )

        $scope.selfAssign = () ->
            save(currentUserId)

        $scope.$watch $attrs.ngModel, (item, currentItem) ->
            return if not item?
            render(item)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link,
        templateUrl: "components/ticket-assigned/assigned-to.html",
        require:"ngModel"
    }

angular.module('taigaComponents').directive("tgAssignedTo", ["$rootScope", "$tgConfirm", "$tgRepo",
"$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$translate", "$compile",
"tgCurrentUserService", "tgAvatarService", "tgLightboxFactory", AssignedToDirective])
