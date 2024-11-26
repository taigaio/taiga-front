###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

NotificationsListDirective = ->
    return {
        templateUrl: "notifications/notifications-list/notifications-list.html",
        controller: "Notifications",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            infiniteScrollContainer: "@",
            infiniteScrollDistance: "=",
            infiniteScrollDisabled: "=",
            onlyUnread: "=onlyUnread"
        }
    }

angular.module("taigaNotifications").directive("tgNotificationsList", NotificationsListDirective)
