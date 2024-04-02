###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
