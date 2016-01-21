###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: doscover-home.controller.spec.coffee
###

describe "DiscoverHomeController", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockLocation = ->
        mocks.location = {}

        $provide.value('$tgLocation', mocks.location)

    _mockNavUrls = ->
        mocks.navUrls = {}

        $provide.value('$tgNavUrls', mocks.navUrls)

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockLocation()
            _mockNavUrls()

            return null

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaDiscover"

        _mocks()
        _setup()

    it "onSubmit redirect to discover search", () ->
        mocks.navUrls.resolve = sinon.stub().withArgs('discover-search').returns('url')

        pathSpy = sinon.spy()
        searchStub = {
            path: pathSpy
        }

        mocks.location.search = sinon.stub().withArgs('text', 'query').returns(searchStub)

        ctrl = $controller("DiscoverHome")

        ctrl.onSubmit('query')

        expect(pathSpy).to.have.been.calledWith('url');
