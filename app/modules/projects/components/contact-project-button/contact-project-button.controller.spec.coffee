###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "ContactProjectButton", ->
    provide = null
    controller = null
    mocks = {}

    _mockTgLightboxFactory = () ->
        mocks.tgLightboxFactory = {
            create: sinon.stub()
        }

        provide.value "tgLightboxFactory", mocks.tgLightboxFactory

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgLightboxFactory()

            return null

    beforeEach ->
        module "taigaProjects"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "Launch Contact Form", () ->
        ctrl = controller("ContactProjectButtonCtrl")
        ctrl.launchContactForm()
        expect(mocks.tgLightboxFactory.create).have.been.called
