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
# File: discover/components/most-active/most-active.controller.spec.coffee
###

describe "MostActive", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockDiscoverProjectsService = ->
        mocks.discoverProjectsService = {
            fetchMostActive: sinon.stub()
        }

        $provide.value("tgDiscoverProjectsService", mocks.discoverProjectsService)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockDiscoverProjectsService()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaDiscover"

        _setup()

    it "fetch", (done) ->
        ctrl = $controller("MostActive")

        ctrl.getOrderBy = sinon.stub().returns('week')

        mockPromise = mocks.discoverProjectsService.fetchMostActive.withArgs(sinon.match({order_by: 'week'})).promise()

        promise = ctrl.fetch()

        expect(ctrl.loading).to.be.true

        mockPromise.resolve()

        promise.finally () ->
            expect(ctrl.loading).to.be.false
            done()


    it "order by", () ->
        ctrl = $controller("MostActive")

        ctrl.fetch = sinon.spy()

        ctrl.orderBy('month')

        expect(ctrl.fetch).to.have.been.called
        expect(ctrl.currentOrderBy).to.be.equal('month')
