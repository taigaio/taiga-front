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
# File: home/home-controller.spec.coffee
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
