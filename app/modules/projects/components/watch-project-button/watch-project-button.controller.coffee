###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
