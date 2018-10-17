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
# File: notifications/notifications.controller.coffee
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

        @rootScope.$on "notifications:updated", (event) =>
            @.reloadList()

    initList: ()->
        @.notificationsList = Immutable.List()
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

                if response.get("next")
                    @.scrollDisabled = false

                @.total = response.get("total")

                @scope.$emit("notifications:loaded", @.total)

                @.loading = false
                return @.notificationsList

    setAsRead: (notification, url) ->
        @.loading = true
        @scope.$emit("notifications:loading")
        @notificationsService.setNotificationAsRead(notification.get("id")).then =>
            if @location.$$url == url
                @window.location.reload()
            else
                @rootScope.$broadcast "notifications:updated"
                @location.path(url)

    setAllAsRead: () ->
        @.loading = true
        @scope.$emit("notifications:loading")
        @notificationsService.setNotificationsAsRead().then =>
            @rootScope.$emit("notifications:updated")


angular.module("taigaNotifications").controller("Notifications", NotificationsController)
