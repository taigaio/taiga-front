###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "HomeController", ->
    homeCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockCurrentUserService = () ->
        mocks.currentUserService = {
            getUser: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUserService

    _mockLocation = () ->
        mocks.location = {
            path: sinon.stub()
        }
        provide.value "$location", mocks.location

    _mockTgNavUrls = () ->
        mocks.tgNavUrls = {
            resolve: sinon.stub()
        }

        provide.value "$tgNavUrls", mocks.tgNavUrls

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockCurrentUserService()
            _mockLocation()
            _mockTgNavUrls()

            return null

    beforeEach ->
        module "taigaHome"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "anonymous home", () ->
        homeCtrl = controller "Home",
            $scope: {}

        expect(mocks.tgNavUrls.resolve).to.be.calledWith("discover")
        expect(mocks.location.path).to.be.calledOnce

    it "non anonymous home", () ->
        mocks.currentUserService = {
            getUser: Immutable.fromJS({
                id: 1
            })
        }

        expect(mocks.tgNavUrls.resolve).to.be.notCalled
        expect(mocks.location.path).to.be.notCalled
