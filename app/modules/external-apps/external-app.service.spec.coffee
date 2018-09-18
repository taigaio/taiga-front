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
# File: external-apps/external-app.service.spec.coffee
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
