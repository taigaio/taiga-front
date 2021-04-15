###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
