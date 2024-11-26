###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgExternalAppsService", ->
    externalAppsService = provide = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            externalapps: {
                getApplicationToken: sinon.stub()
                authorizeApplicationToken: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResources

    _inject = (callback) ->
        inject (_tgExternalAppsService_) ->
            externalAppsService = _tgExternalAppsService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgResources()
            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaExternalApps"
        _setup()
        _inject()

    it "getApplicationToken", () ->
        expect(mocks.tgResources.externalapps.getApplicationToken.callCount).to.be.equal(0)
        externalAppsService.getApplicationToken(6, "testing-state")
        expect(mocks.tgResources.externalapps.getApplicationToken.callCount).to.be.equal(1)
        expect(mocks.tgResources.externalapps.getApplicationToken.calledWith(6, "testing-state")).to.be.true

    it "authorizeApplicationToken", () ->
        expect(mocks.tgResources.externalapps.authorizeApplicationToken.callCount).to.be.equal(0)
        externalAppsService.authorizeApplicationToken(6, "testing-state")
        expect(mocks.tgResources.externalapps.authorizeApplicationToken.callCount).to.be.equal(1)
        expect(mocks.tgResources.externalapps.authorizeApplicationToken.calledWith(6, "testing-state")).to.be.true
