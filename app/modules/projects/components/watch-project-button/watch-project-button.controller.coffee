###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class WatchProjectButtonController
    @.$inject = [
        "$tgConfirm"
        "tgWatchProjectButtonService"
    ]

    constructor: (@confirm, @watchButtonService)->
        @.showWatchOptions = false
        @.loading = false

    toggleWatcherOptions: () ->
        @.showWatchOptions = !@.showWatchOptions

    closeWatcherOptions: () ->
        @.showWatchOptions = false

    watch: (notifyLevel) ->
        return if notifyLevel == @.project.get('notify_level')

        @.loading = true
        @.closeWatcherOptions()

        return @watchButtonService.watch(@.project.get('id'), notifyLevel)
            .catch () => @confirm.notify("error")
            .finally () => @.loading = false

    unwatch: ->
        @.loading = true
        @.closeWatcherOptions()

        return @watchButtonService.unwatch(@.project.get('id'))
            .catch () => @confirm.notify("error")
            .finally () => @.loading = false

angular.module("taigaProjects").controller("WatchProjectButton", WatchProjectButtonController)
