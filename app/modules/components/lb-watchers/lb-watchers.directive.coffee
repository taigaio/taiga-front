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

truncate = taiga.truncate

WatchersLightboxDirective = (
    $rootScope
    $repo
    lightboxService
    lightboxKeyboardNavigationService
    avatarService
    projectService
) ->
    link = ($scope, $el, $attrs) ->
        users = []
        roles = []

        getFilteredUsers = (text="") ->
            selected = _.sortBy(
                _.filter(users, (x) ->
                    _.includes($scope.watchers, x.id)
                ),
                'name'
            )

            _filterRows = (text, row) ->
                if row.type == 'user' && _.find(selected, ['id', row.id])
                    return false

                name = row.name.toUpperCase()
                text = text.toUpperCase()
                return _.includes(name, text)

            collection = users
            if text
                collection = _.union(users, roles)
            available = _.sortBy(
                _.filter(collection, _.partial(_filterRows, text)),
                'name'
            )

            if !text
                $scope.selected = selected
                $scope.collection = _.union(selected, available)
            else
                $scope.selected = []
                $scope.collection = available

        closeLightbox = () ->
            lightboxKeyboardNavigationService.stop()
            lightboxService.close($el)

        $scope.$on "watcher:add", (ctx, item) ->
            $scope.item = item
            getFilteredUsers()

            lightboxService.open($el).then ->
                $el.find("input").focus()
                lightboxKeyboardNavigationService.init($el)

        $scope.$watch "activeUsers", (activeUsers) ->
            if not activeUsers
                return

            users = _.map activeUsers, (user) ->
                return {
                    id: user.id,
                    type: 'user',
                    name: user.full_name_display,
                    avatar: avatarService.getAvatar(user),
                }

            project = projectService.project.toJS()
            roles = _.map project.roles, (role) ->
                roleUsers = _.filter(activeUsers, {'role': role.id})
                return {
                    id: role.id,
                    type: 'role',
                    name: role.name,
                    avatar: null,
                    userIds: _.map(roleUsers, 'id')
                    userNames: truncate('(' + _.join(_.map(roleUsers, 'full_name_display'), ', ') + ')', 110)
                }

        $scope.$watch "watchers", (watchers) ->
            if not watchers
                return
            getFilteredUsers()

        $scope.$watch "searchText", (searchingText) ->
            getFilteredUsers(searchingText)
            $el.find("input").focus()

        $scope.removeItem = (user, $event) ->
            $event.preventDefault()
            $event.stopPropagation()
            $event.currentTarget.remove()

            $scope.searchText = null
            _.pull($scope.watchers, user.id)
            getFilteredUsers()

        $scope.addItem = (item) ->
            if item.type == 'user'
                return if _.find($scope.selected, ['id', item.id])
                $scope.watchers.push(item.id)

            if item.type == 'role'
                $scope.watchers = _.union($scope.watchers, item.userIds)

            $scope.searchText = null
            getFilteredUsers()

        $scope.clearSearch = () ->
            $scope.searchText = ''

        $scope.confirmSelection = () ->
            closeLightbox()
            $rootScope.$broadcast('watchers:changed', $scope.watchers)

        $el.on "click", ".close", (event) ->
            event.preventDefault()

            closeLightbox()

            $scope.$apply ->
                $scope.searchText = null

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
    "tgProjectService"
]

angular.module("taigaComponents").directive("tgLbWatchers", WatchersLightboxDirective)
