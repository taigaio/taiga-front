###
# Copyright (C) 2014-2018 Taiga Agile LLC <taiga@taiga.io>
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
# File: assigned-to.directive.coffee
###

AssignToDirective = ($rootscope, $confirm, $repo, $loading, $modelTransform, $template,
$translate, $compile, $auth, avatarService) ->
    template = $template.get( "components/assign/assign-to.html", true)

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

            transform.then ->
                currentLoading.finish()
                renderAssignedTo($modelTransform.getObj())
                $rootscope.$broadcast("object:updated")

            transform.then null, ->
                $confirm.notify("error")
                currentLoading.finish()

            return transform

        renderAssignedTo = (assignedObject) ->
            avatar = avatarService.getAvatar(assignedObject?.assigned_to_extra_info)
            bg = null

            if assignedObject?.assigned_to?
                fullName = assignedObject.assigned_to_extra_info.full_name_display
                isUnassigned = false
                bg = avatar.bg
            else
                fullName = $translate.instant("COMMON.ASSIGNED_TO.ASSIGN")
                isUnassigned = true

            isIocaine = assignedObject?.is_iocaine

            ctx = {
                fullName: fullName
                avatar: avatar.url
                bg: bg
                isUnassigned: isUnassigned
                isEditable: isEditable()
                isIocaine: isIocaine
                fullNameVisible: !(isUnassigned && !$auth.isAuthenticated())
            }
            html = $compile(template(ctx))($scope)
            $el.html(html)

        $el.on "click", ".user-assigned", (event) ->
            event.preventDefault()
            return if not isEditable()
            $scope.$apply ->
                $rootscope.$broadcast("assigned-to:add", $model.$modelValue)

        $el.on "click", ".self-assign", (event) ->
            event.preventDefault()
            return if not isEditable()
            currentUser = $auth.getUser()
            $model.$modelValue.assigned_to = currentUser.id
            save(currentUser.id)

        $el.on "click", ".remove-user", (event) ->
            event.preventDefault()
            return if not isEditable()
            title = $translate.instant("COMMON.ASSIGNED_TO.CONFIRM_UNASSIGNED")

            $confirm.ask(title).then (response) ->
                response.finish()
                $model.$modelValue.assigned_to  = null
                save(null)

        $scope.$on "assigned-to:added", (ctx, userId, item) ->
            return if item.id != $model.$modelValue.id
            save(userId)

        $scope.$watch $attrs.ngModel, (instance) ->
            renderAssignedTo(instance)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link,
        require:"ngModel"
    }

angular.module('taigaComponents').directive("tgAssignedTo", ["$rootScope", "$tgConfirm", "$tgRepo",
"$tgLoading", "$tgQueueModelTransformation", "$tgTemplate", "$translate", "$compile", "$tgAuth",
"tgAvatarService", AssignToDirective])
