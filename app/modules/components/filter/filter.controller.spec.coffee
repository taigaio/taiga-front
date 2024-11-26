###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "Filter", ->
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
        ctrl.customFilters = []
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
        ctrl.customFilters = []
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
