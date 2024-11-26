###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
