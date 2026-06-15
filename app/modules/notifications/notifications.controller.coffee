###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

mixOf = @.taiga.mixOf
debounceLeading = @.taiga.debounceLeading

class NotificationsController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$rootScope",
        "$scope",
        "tgNotificationsService"
        "tgCurrentUserService",
        "$tgEvents",
        "$location"
        "$window"
    ]

    constructor: (@rootScope, @scope, @notificationsService, @currentUserService, @events,
    @location, @window) ->
        @.total = 0
        @.user = @currentUserService.getUser()
        @.scrollDisabled = false
        @.initList()
        @.loadNotifications()

        @rootScope.$on "notifications:dismiss", (event) =>
            if @.onlyUnread
                @.reloadList()

        @rootScope.$on "notifications:new", (event) =>
            @.reloadList()

        @rootScope.$on "notifications:dismiss-all", (event) =>
            @.reloadList()

    initList: ()->
        @.notificationsList = Immutable.List()
        if @.user
            @.list = @notificationsService.getNotificationsList(@.user.get("id"), @.onlyUnread?)

        @.loading = !@.list?

    reloadList: ()->
        @.initList()
        @.loadNotifications()

    loadNotifications: () ->
        @.scrollDisabled = true
        @.loading = true
        @scope.$emit("notifications:loading")
        return @.list
            .next()
            .then (response) =>
                @.notificationsList = @.notificationsList.concat(response.get("items"))

                if !@.infiniteScrollDisabled && response.get("next")
                    @.scrollDisabled = false

                @.total = response.get("total")

                @scope.$emit("notifications:loaded", @.total)

                @.loading = false
                return @.notificationsList

    setAsRead: (notification, url, event) ->
        # Modifier-clicks (ctrl/cmd/shift, and the legacy middle-click some
        # browsers still report as a click) follow the real href to open a new
        # tab/window natively, so here we only mark the notification as read.
        if event? and (event.ctrlKey or event.metaKey or event.shiftKey or event.which > 1)
            @notificationsService.setNotificationAsRead(notification.get("id")).then(angular.noop, angular.noop)
            @rootScope.$broadcast "notifications:dismiss"
            return

        # Plain left-click: navigate within the SPA ourselves, so prevent the
        # browser from also following the href (which would full-reload the page).
        event.preventDefault() if event?

        @notificationsService.setNotificationAsRead(notification.get("id")).then =>
            if @location.$$url == url
                @window.location.reload()
            else
                @location.path(url)

            @rootScope.$broadcast "notifications:dismiss"

    setAllAsRead: () ->
        @notificationsService.setNotificationsAsRead().then =>
            @rootScope.$broadcast "notifications:dismiss-all"


angular.module("taigaNotifications").controller("Notifications", NotificationsController)
