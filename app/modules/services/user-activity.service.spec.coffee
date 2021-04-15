###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

angular.module("taigaCommon").provider("$exceptionHandler", angular.mock.$ExceptionHandlerProvider)

describe "UserActivityService", ->
    userActivityService = null
    $timeout = null

    _inject = () ->
        inject (_tgUserActivityService_, _$timeout_) ->
            userActivityService = _tgUserActivityService_
            $timeout = _$timeout_

    beforeEach ->
        module "taigaCommon"
        _inject()

    it "inactive", (done) ->
        active = sinon.spy()
        userActivityService.onInactive () ->
            expect(active).not.to.have.been.called;
            done()

        userActivityService.onActive(active)

        $timeout.flush()

    it "unsubscribe inactive", (done) ->
        unsubscribe = userActivityService.onInactive () ->
            unsubscribe()

            expect(userActivityService.subscriptionsInactive).to.have.length(0)

            done()

        expect(userActivityService.subscriptionsInactive).to.have.length(1)

        $timeout.flush()

    it "active", (done) ->
        inactive = sinon.spy()
        userActivityService.onInactive(inactive)

        userActivityService.onActive () ->
            expect(inactive).to.have.been.called;
            done()

        $timeout.flush()
        userActivityService.resetTimer()

    it "unsubscribe active", (done) ->
        unsubscribe = userActivityService.onActive () ->
            unsubscribe()

            expect(userActivityService.subscriptionsActive).to.have.length(0)

            done()

        expect(userActivityService.subscriptionsActive).to.have.length(1)

        $timeout.flush()
        userActivityService.resetTimer()
