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
# File: feedback/feedback.service.spec.coffee
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
