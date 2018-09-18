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
# File: discover/components/discover-home-order-by/discover-home-order-by.controller.spec.coffee
###

describe "DiscoverHomeOrderBy", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockTranslate = ->
        mocks.translate = {
            instant: sinon.stub()
        }

        $provide.value("$translate", mocks.translate)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTranslate()

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

    it "get current search text", () ->
        mocks.translate.instant.withArgs('DISCOVER.FILTERS.WEEK').returns('week')
        mocks.translate.instant.withArgs('DISCOVER.FILTERS.MONTH').returns('month')

        ctrl = $controller("DiscoverHomeOrderBy")

        ctrl.currentOrderBy = 'week'
        text = ctrl.currentText()

        expect(text).to.be.equal('week')

        ctrl.currentOrderBy = 'month'
        text = ctrl.currentText()

        expect(text).to.be.equal('month')

    it "open", () ->
        ctrl = $controller("DiscoverHomeOrderBy")

        ctrl.is_open = false

        ctrl.open()

        expect(ctrl.is_open).to.be.true

    it "close", () ->
        ctrl = $controller("DiscoverHomeOrderBy")

        ctrl.is_open = true

        ctrl.close()

        expect(ctrl.is_open).to.be.false

    it "order by", () ->
        ctrl = $controller("DiscoverHomeOrderBy")
        ctrl.onChange = sinon.spy()

        ctrl.orderBy('week')


        expect(ctrl.currentOrderBy).to.be.equal('week')
        expect(ctrl.is_open).to.be.false
        expect(ctrl.onChange).to.have.been.calledWith({orderBy: 'week'})
