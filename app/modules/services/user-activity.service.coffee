###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
