###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "MostLiked", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockDiscoverProjectsService = ->
        mocks.discoverProjectsService = {
            fetchMostLiked: sinon.stub()
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
        ctrl = $controller("MostLiked")

        ctrl.getOrderBy = sinon.stub().returns('week')

        mockPromise = mocks.discoverProjectsService.fetchMostLiked.withArgs(sinon.match({order_by: 'week'})).promise()

        promise = ctrl.fetch()

        expect(ctrl.loading).to.be.true

        mockPromise.resolve()

        promise.finally () ->
            expect(ctrl.loading).to.be.false
            done()


    it "order by", () ->
        ctrl = $controller("MostLiked")

        ctrl.fetch = sinon.spy()

        ctrl.orderBy('month')

        expect(ctrl.fetch).to.have.been.called
        expect(ctrl.currentOrderBy).to.be.equal('month')
