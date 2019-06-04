###
# Copyright (C) 2014-2019 Taiga Agile LLC
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
# File: components/lb-watchers/lb-watchers.directive.coffee
###

WatchersLightboxDirective = (
    $rootScope
    $repo
    lightboxService
    lightboxKeyboardNavigationService
    avatarService
) ->
    link = ($scope, $el, $attrs) ->
        activeUsers = []
        getFilteredUsers = (text="") ->
            selected = _.sortBy(
                _.filter(activeUsers, (x) ->
                    _.includes($scope.watchers, x.id)
                ),
                'full_name_display'
            )

            _filterUsers = (text, user) ->
                if _.find(selected, ['id', user.id])
                    return false

                username = user.full_name_display.toUpperCase()
                text = text.toUpperCase()
                return _.includes(username, text)

            available = _.sortBy(
                _.filter(activeUsers, _.partial(_filterUsers, text)),
                'full_name_display'
            )

            if !text
                $scope.selected = selected
                $scope.users = _.union(selected, available)
            else
                $scope.selected = []
                $scope.users = available

        closeLightbox = () ->
            lightboxKeyboardNavigationService.stop()
            lightboxService.close($el)

        $scope.$on "watcher:add", (ctx, item) ->
            $scope.item = item
            getFilteredUsers()

            lightboxService.open($el).then ->
                $el.find("input").focus()
                lightboxKeyboardNavigationService.init($el)

        $scope.$watch "activeUsers", (users) ->
            if not users
                return

            activeUsers = _.map users, (user) ->
                user.avatar = avatarService.getAvatar(user)
                return user

        $scope.$watch "watchers", (watchers) ->
            if not watchers
                return
            getFilteredUsers()

        $scope.$watch "usersSearch", (searchingText) ->
            users = getFilteredUsers(searchingText)
            $el.find("input").focus()

        $scope.removeUser = (user, $event) ->
            $event.preventDefault()
            $event.stopPropagation()
            $event.currentTarget.remove()

            $scope.usersSearch = null
            _.pull($scope.watchers, user.id)
            getFilteredUsers()

        $scope.addUser = (user) ->
            if _.find($scope.selected, ['id', user.id])
                return

            $scope.usersSearch = null
            $scope.watchers.push(user.id)
            getFilteredUsers()

        $scope.clearSearch = () ->
            $scope.usersSearch = ''

        $scope.confirmSelection = () ->
            closeLightbox()
            $rootScope.$broadcast('watchers:changed', $scope.watchers)

        $el.on "click", ".close", (event) ->
            event.preventDefault()

            closeLightbox()

            $scope.$apply ->
                $scope.usersSearch = null

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "components/lb-watchers/lb-watchers.html"
        link: link
        scope: {
            activeUsers: "="
            watchers: "="
        }
    }

WatchersLightboxDirective.$inject = [
    "$rootScope"
    "$tgRepo"
    "lightboxService"
    "lightboxKeyboardNavigationService"
    "tgAvatarService"
]

angular.module("taigaComponents").directive("tgLbWatchers", WatchersLightboxDirective)
