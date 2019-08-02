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
# File: components/watch-button/watch-button.controller.coffee
###

class TicketWatchersController
    @.$inject = [
        "tgCurrentUserService"
        "$rootScope"
        "tgLightboxFactory"
        "$translate",
        "$tgQueueModelTransformation",
    ]

    constructor: (@currentUserService, @rootScope, @lightboxFactory, @translate, @modelTransform) ->
        @.user = @currentUserService.getUser()
        @.loading = false

    openWatchers: ->
        onClose = (watchersIds) => @.save(watchersIds)

        @lightboxFactory.create(
            'tg-lb-select-user',
            {
                "class": "lightbox lightbox-select-user",
            },
            {
                "currentUsers": @.item.watchers,
                "activeUsers": @.activeUsers,
                "onClose": onClose,
                "lbTitle": @translate.instant("COMMON.WATCHERS.ADD"),
            }
        )

    getPerms: ->
        return "" if !@.item

        name = @.item._name

        perms = {
            userstories: 'modify_us',
            issues: 'modify_issue',
            tasks: 'modify_task',
            epics: 'modify_epic'
        }

        return perms[name]

    watch: ->
        @.loading = true
        promise = @._watch()
        promise.finally () => @.loading = false
        return promise

    unwatch: ->
        @.loading = true
        promise = @._unwatch()
        promise.finally () => @.loading = false
        return promise

    deleteWatcher: (watcherId) ->
        watchersIds = _.filter(@.item.watchers, (x) => x != watcherId)
        @.save(watchersIds)

    save: (watchersIds) ->
        @.loading = true
        transform = @modelTransform.save (item) ->
            item.watchers = watchersIds
            return item
        transform.then =>
            @rootScope.$broadcast("object:updated")
        transform.finally () => @.loading = false

    _watch: ->
        @.onWatch()

    _unwatch: ->
        @.onUnwatch()

angular.module("taigaComponents").controller("TicketWatchersController", TicketWatchersController)
