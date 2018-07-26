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
# File: assigned-users-lightbox.directive.coffee
###

debounce = @.taiga.debounce

AssignedUsersLightboxDirective = ($repo, lightboxService, lightboxKeyboardNavigationService,
$template, $compile, avatarService) ->
    link = ($scope, $el, $attrs) ->
        selectedUsers = []
        selectedItem = null
        usersTemplate = $template.get("components/assign-lightbox/user-list-multiple.html", true)

        normalizeString = (string) ->
            normalizedString = string
            normalizedString = normalizedString.replace("Á", "A").replace("Ä", "A").replace("À", "A")
            normalizedString = normalizedString.replace("É", "E").replace("Ë", "E").replace("È", "E")
            normalizedString = normalizedString.replace("Í", "I").replace("Ï", "I").replace("Ì", "I")
            normalizedString = normalizedString.replace("Ó", "O").replace("Ö", "O").replace("Ò", "O")
            normalizedString = normalizedString.replace("Ú", "U").replace("Ü", "U").replace("Ù", "U")
            return normalizedString

        filterUsers = (text, user) ->
            username = user.full_name_display.toUpperCase()
            username = normalizeString(username)
            text = text.toUpperCase()
            text = normalizeString(text)

            return _.includes(username, text)

        # Render the specific list of users.
        render = (assignedUsersIds, text) ->
            users = _.clone($scope.activeUsers, true)
            users = _.sortBy(users, (o) -> if o.id is $scope.user.id then 0 else o.id)
            users = _.filter(users, _.partial(filterUsers, text)) if text?

            # Add selected users
            selected = []
            _.map users, (user) ->
                if user.id in assignedUsersIds
                    user.avatar = avatarService.getAvatar(user)
                    selected.push(user)

            # Filter users in searchs

            visible = []
            _.map users, (user) ->
                if user.id not in assignedUsersIds
                    user.avatar = avatarService.getAvatar(user)
                    visible.push(user)

            ctx = {
                selected: selected
                users:  _.slice(visible, 0, 5)
                showMore: users.length > 5
            }

            html = usersTemplate(ctx)
            html = $compile(html)($scope)
            $el.find(".assigned-to-list").html(html)

        closeLightbox = () ->
            lightboxKeyboardNavigationService.stop()
            lightboxService.close($el)

        $scope.$on "assigned-user:add", (ctx, item) ->
            selectedItem = item
            selectedUsers = item.assigned_users
            render(selectedUsers)

            lightboxService.open($el).then ->
                $el.find("input").focus()
                lightboxKeyboardNavigationService.init($el)

        $scope.$watch "usersSearch", (searchingText) ->
            if searchingText?
                render(selectedUsers, searchingText)
                $el.find('input').focus()

        $el.on "click", ".user-list-single", debounce 200, (event) ->
            closeLightbox()

            event.preventDefault()
            target = angular.element(event.currentTarget)

            $scope.$apply ->
                $scope.usersSearch = null
                $scope.$broadcast("assigned-user:added", target.data("user-id"), selectedItem)

        $el.on "click", ".remove-assigned-to", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            event.stopPropagation()

            $scope.$apply ->
                $scope.usersSearch = null
                $scope.$broadcast("assigned-user:deleted", target.data("user-id"), selectedItem)
            closeLightbox()

        $el.on "click", ".close", (event) ->
            event.preventDefault()

            closeLightbox()

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "components/assign-lightbox/assigned-users-lightbox.html"
        link:link
    }

angular.module('taigaComponents').directive("tgLbAssignedUsers", ["$tgRepo", "lightboxService",
"lightboxKeyboardNavigationService", "$tgTemplate", "$compile", "tgAvatarService",
AssignedUsersLightboxDirective])
