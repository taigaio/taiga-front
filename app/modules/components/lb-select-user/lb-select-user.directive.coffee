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
# File: components/lb-select-user/lb-select-user.directive.coffee
###

truncate = taiga.truncate

SelectUserDirective = (
    $rootScope
    $repo
    $translate
    lightboxService
    lightboxKeyboardNavigationService
    avatarService
    projectService
) ->
    link = ($scope, $el, $attrs) ->
        users = []
        roles = []
        lightboxService.open($el)

        getFilteredUsers = (text="") ->
            selected = _.compact(_.sortBy(
                _.filter(users, (x) ->
                    _.includes($scope.currentUsers, x.id)
                ),
                'name'
            ))

            _filterRows = (text, row) ->
                if row.type == 'user' && _.find(selected, ['id', row.id])
                    return false

                name = row.name.toUpperCase()
                text = text.toUpperCase()
                return _.includes(name, text)

            collection = _.union(
                users,
                _.filter(roles, (role) =>
                    difference = _.difference(role.userIds, _.map(selected, 'id'))
                    return difference.length > 0
                )
            )
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
            return if not activeUsers

            users = _.map activeUsers, (user) ->
                return {
                    id: user.id,
                    type: 'user',
                    name: user.full_name_display,
                    avatar: avatarService.getAvatar(user),
                }

            return if $scope.single

            project = projectService.project.toJS()
            roles = _.map project.roles, (role) ->
                roleUsers = _.filter(activeUsers, {'role': role.id})
                suffix = $translate.instant("LIGHTBOX.SELECT_USER.ROLE")
                return {
                    id: role.id,
                    type: 'role',
                    name: "#{suffix}: #{role.name}",
                    avatar: null,
                    userIds: _.map(roleUsers, 'id')
                    userNames: truncate('(' + _.join(_.map(roleUsers, 'full_name_display'), ', ') + ')', 110)
                }

        $scope.$watch "currentUsers", (currentUsers) ->
            if not currentUsers
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
            _.pull($scope.currentUsers, user.id)
            getFilteredUsers()

        $scope.addItem = (item) ->
            if item.type == 'user'
                return if _.find($scope.currentUsers, ['id', item.id])
                if $scope.single
                    $scope.currentUsers = [item.id]
                    confirmSelection()
                    return
                $scope.currentUsers.push(item.id)

            if item.type == 'role'
                $scope.currentUsers = _.union($scope.currentUsers, item.userIds)

            $scope.searchText = null
            getFilteredUsers()

        $scope.clearSearch = () ->
            $scope.searchText = ''

        confirmSelection = () ->
            $scope.loading = true
            $scope.onClose($scope.currentUsers)
            closeLightbox()
            $scope.loading = false

        $el.on "click", ".lb-select-user-confirm", (event) ->
            return if $scope.loading
            event.preventDefault()
            confirmSelection()

        $el.on "click", ".close", (event) ->
            event.preventDefault()

            closeLightbox()
            $scope.$apply ->
                $scope.searchText = null

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "components/lb-select-user/lb-select-user.html"
        link: link
        scope: true
    }

SelectUserDirective.$inject = [
    "$rootScope"
    "$tgRepo"
    "$translate"
    "lightboxService"
    "lightboxKeyboardNavigationService"
    "tgAvatarService"
    "tgProjectService"
]

angular.module("taigaComponents").directive("tgLbSelectUser", SelectUserDirective)
