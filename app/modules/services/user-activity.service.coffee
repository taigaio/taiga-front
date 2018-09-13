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
# File: services/user-activity.service.coffee
###

taiga = @.taiga

groupBy = @.taiga.groupBy

class UserActivityService
    @.$inject = ['$timeout']

    idleTimeout: 60 * 5 * 1000

    constructor: (@timeout) ->
        return null if window.localStorage.e2e

        window.addEventListener('mousemove', @.resetTimer.bind(this), false)
        window.addEventListener('mousedown', @.resetTimer.bind(this), false)
        window.addEventListener('keypress', @.resetTimer.bind(this), false)
        window.addEventListener('mousewheel', @.resetTimer.bind(this), false)
        window.addEventListener('touchmove', @.resetTimer.bind(this), false)

        @.subscriptionsActive = []
        @.subscriptionsInactive = []
        @.isActive = true

        @.startTimer()

    startTimer: () ->
        @.timerId = @timeout(@._fireInactive.bind(this), @.idleTimeout)

    resetTimer: () ->
        if !@.isActive
            @._fireActive()

        @timeout.cancel(@.timerId)
        @.startTimer()

        @.isActive = true

    onActive: (cb) ->
        @.subscriptionsActive.push(cb)

        return @._unSubscriptionsActive.bind(this, cb)

    onInactive: (cb) ->
        @.subscriptionsInactive.push(cb)

        return @._unSubscriptionsInactive.bind(this, cb)

    _fireActive: () ->
        @.subscriptionsActive.forEach (it) -> it()

    _fireInactive: () ->
        @.isActive = false
        @.subscriptionsInactive.forEach (it) -> it()

    _unSubscriptionsActive: (cb) ->
        @.subscriptionsActive = @.subscriptionsActive.filter (fn) -> fn != cb

    _unSubscriptionsInactive: (cb) ->
        @.subscriptionsInactive = @.subscriptionsInactive.filter (fn) -> fn != cb

angular.module("taigaCommon").service("tgUserActivityService", UserActivityService)
