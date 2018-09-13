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
$translate, $compile, $currentUserService, avatarService) ->
    # You have to include a div with the tg-lb-assignedto directive in the page
    # where use this directive
    template = $template.get("common/components/assigned-to.html", true)

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project?.my_permissions?.indexOf($attrs.requiredPerm) != -1

        save = (userId) ->
            item = $model.$modelValue.clone()
            item.assigned_to = userId

            currentLoading = $loading()
                .target($el)
                .start()

            transform = $modelTransform.save (item) ->
                item.assigned_to = userId
                return item

            transform.then (item) ->
                currentLoading.finish()
                $rootscope.$broadcast("object:updated")

            transform.then null, ->
                $confirm.notify("error")
                currentLoading.finish()

            return transform

        render = () ->
            template = $template.get("common/components/assigned-to.html")
            templateScope = $scope.$new()
            compiledTemplate = $compile(template)(templateScope)
            $el.html(compiledTemplate)

        $scope.assign = () ->
            $rootscope.$broadcast("assigned-to:add", $model.$modelValue)

        $scope.unassign = () ->
            title = $translate.instant("COMMON.ASSIGNED_TO.CONFIRM_UNASSIGNED")
            $confirm.ask(title).then (response) ->
                response.finish()
                save(null)

        $scope.selfAssign = () ->
            userId = $currentUserService.getUser().get('id')
            save(userId)

        $scope.$on "assigned-to:added", (ctx, userId, item) ->
            return if item.id != $model.$modelValue.id
            save(userId)

        $scope.$watch $attrs.ngModel, (instance) ->
            if instance?.assigned_to
                $scope.selected = instance.assigned_to
                assigned_to_extra_info = $scope.usersById[$scope.selected]
                $scope.fullName = assigned_to_extra_info?.full_name_display
                $scope.isUnassigned = false
                $scope.avatar = avatarService.getAvatar(assigned_to_extra_info)
                $scope.bg = $scope.avatar.bg
                $scope.isIocaine = instance?.is_iocaine
            else
                $scope.fullName = $translate.instant("COMMON.ASSIGNED_TO.ASSIGN")
                $scope.isUnassigned = true
                $scope.avatar = avatarService.getAvatar(null)
                $scope.bg = null
                $scope.isIocaine = false

            $scope.fullNameVisible = !($scope.isUnassigned && !$currentUserService.isAuthenticated())
            $scope.isEditable = isEditable()
            render()

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link,
        require:"ngModel"
    }

angular.module('taigaComponents').directive("tgAssignedTo", ["$rootScope", "$tgConfirm", "$tgRepo",
"$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$translate", "$compile",
"tgCurrentUserService", "tgAvatarService", AssignedToDirective])
