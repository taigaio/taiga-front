###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "DiscoverSearchBarController", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockDiscoverProjectsService = ->
        mocks.discoverProjectsService = {
            fetchStats: sinon.spy()
        }

        $provide.value('tgDiscoverProjectsService', mocks.discoverProjectsService)

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockDiscoverProjectsService()

            return null

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaDiscover"

        _mocks()
        _setup()

    it "select filter", () ->
        ctrl = $controller("DiscoverSearchBar")
        ctrl.onChange = sinon.spy()
        ctrl.q = 'query'

        ctrl.selectFilter('text')

        expect(mocks.discoverProjectsService.fetchStats).to.have.been.called
        expect(ctrl.onChange).to.have.been.calledWith(sinon.match({filter: 'text', q: 'query'}))

    it "submit filter", () ->
        ctrl = $controller("DiscoverSearchBar")
        ctrl.filter = 'all'
        ctrl.q = 'query'
        ctrl.onChange = sinon.spy()

        ctrl.submitFilter()

        expect(mocks.discoverProjectsService.fetchStats).to.have.been.called
        expect(ctrl.onChange).to.have.been.calledWith(sinon.match({filter: 'all', q: 'query'}))
