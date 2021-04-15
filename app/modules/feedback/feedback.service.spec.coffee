###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "tgFeedbackService", ->
    feedbackService = provide = null
    mocks = {}

    _mockTgLightboxFactory = () ->
        mocks.tgLightboxFactory = {
            create: sinon.stub()
        }

        provide.value "tgLightboxFactory", mocks.tgLightboxFactory

    _inject = (callback) ->
        inject (_tgFeedbackService_) ->
            feedbackService = _tgFeedbackService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgLightboxFactory()
            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaFeedback"
        _setup()
        _inject()

    it "work in progress filled", () ->
        expect(mocks.tgLightboxFactory.create.callCount).to.be.equal(0)
        feedbackService.sendFeedback()
        expect(mocks.tgLightboxFactory.create.callCount).to.be.equal(1)
        params = {
            "class": "lightbox lightbox-feedback lightbox-generic-form"
        }
        expect(mocks.tgLightboxFactory.create.calledWith("tg-lb-feedback", params)).to.be.true
