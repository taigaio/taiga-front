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
# File: services/xhrError.service.spec.coffee
###

describe "tgXhrErrorService", ->
    xhrErrorService = provide = null
    mocks = {}

    _mockQ = () ->
        mocks.q = {
            reject: sinon.spy()
        }

        provide.value "$q", mocks.q


    _mockErrorHandling = () ->
        mocks.errorHandling = {
            notfound: sinon.stub(),
            permissionDenied: sinon.stub()
        }

        provide.value "tgErrorHandlingService", mocks.errorHandling

    _inject = (callback) ->
        inject (_tgXhrErrorService_) ->
            xhrErrorService = _tgXhrErrorService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockQ()
            _mockErrorHandling()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaCommon"
        _setup()
        _inject()

    it "404 status redirect to not-found page", () ->
        xhr = {
            status: 404
        }

        xhrErrorService.response(xhr)

        expect(mocks.q.reject.withArgs(xhr)).to.be.calledOnce
        expect(mocks.errorHandling.notfound).to.be.calledOnce

    it "403 status redirect to permission-denied page", () ->
        xhr = {
            status: 403
        }

        xhrErrorService.response(xhr)

        expect(mocks.q.reject.withArgs(xhr)).to.be.calledOnce
        expect(mocks.errorHandling.permissionDenied).to.be.calledOnce
