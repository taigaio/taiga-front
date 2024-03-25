###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
