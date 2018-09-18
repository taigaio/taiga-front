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
# File: projects/components/watch-project-button/watch-project-button.controller.coffee
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
