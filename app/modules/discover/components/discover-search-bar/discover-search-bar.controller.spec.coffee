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
# File: discover/components/discover-search-bar/discover-search-bar.controller.spec.coffee
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
