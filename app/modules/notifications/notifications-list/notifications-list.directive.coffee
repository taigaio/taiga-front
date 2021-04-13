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
