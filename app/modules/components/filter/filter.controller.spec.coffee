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
# File: components/filter/filter.controller.spec.coffee
###

describe "Filter", ->
    $provide = null
    $controller = null
    mocks = {}

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaComponents"

        _setup()

    it "toggle filter category", () ->
        ctrl = $controller("Filter")

        ctrl.toggleFilterCategory('filter1')

        expect(ctrl.opened).to.be.equal('filter1')

        ctrl.toggleFilterCategory('filter1')

        expect(ctrl.opened).to.be.null

    it "is filter open", () ->
        ctrl = $controller("Filter")
        ctrl.opened = 'filter1'

        isOpen = ctrl.isOpen('filter1')

        expect(isOpen).to.be.true

    it "save custom filter", () ->
        ctrl = $controller("Filter")
        ctrl.customFilterName = "custom-name"
        ctrl.customFilterForm = true
        ctrl.onSaveCustomFilter = sinon.spy()

        ctrl.saveCustomFilter()

        expect(ctrl.onSaveCustomFilter).to.have.been.calledWith({name: "custom-name"})
        expect(ctrl.customFilterForm).to.be.false
        expect(ctrl.opened).to.be.equal('custom-filter')
        expect(ctrl.customFilterName).to.be.equal('')

    it "is filter selected", () ->
        ctrl = $controller("Filter")
        ctrl.selectedFilters = [
            {id: 1, dataType: "1"},
            {id: 2, dataType: "2"},
            {id: 3, dataType: "3"}
        ]

        filterCategory = {dataType: "x"}
        filter = {id: 1}
        isFilterSelected = ctrl.isFilterSelected(filterCategory, filter)

        expect(isFilterSelected).to.be.false

        filterCategory = {dataType: "1"}
        filter = {id: 1}
        isFilterSelected = ctrl.isFilterSelected(filterCategory, filter)

        expect(isFilterSelected).to.be.true
