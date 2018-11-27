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
# File: navigation-bar/dropdown-notifications/dropdown-notifications.directive.coffee
###

timeout = @.taiga.timeout

DropdownNotificationsDirective = ($rootScope, notificationsService, currentUserService) ->
    link = ($scope, $el, $attrs, $ctrl) ->
        $scope.notificationsList = []
        $scope.loading = false

        $scope.$on "notifications:loaded", (event, total) ->
            $scope.loading = false
            if $scope.total != undefined && total > $scope.total
                $scope.newEvent = true
                timeout 100, ->
                    $scope.total = total
                    $scope.$apply()
                timeout 2000, ->
                    $scope.newEvent = false
            else
                $scope.total = total

        $scope.$on "notifications:loading", () ->
            $scope.loading = true

        $scope.setAllAsRead = () ->
            notificationsService.setNotificationsAsRead().then ->
                $rootScope.$emit("notifications:dismiss-all")

    directive = {
        templateUrl: "navigation-bar/dropdown-notifications/dropdown-notifications.html"
        scope: {
            active: "="
        }
        link: link
    }

    return directive

angular.module("taigaNavigationBar")
    .directive("tgDropdownNotifications", ["$rootScope", "tgNotificationsService",
    "tgCurrentUserService", DropdownNotificationsDirective])
