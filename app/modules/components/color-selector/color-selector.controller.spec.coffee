###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "ColorSelector", ->
    provide = null
    controller = null
    colorSelectorCtrl = null
    mocks = {}

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            hasPermission: sinon.stub()
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgProjectService()

            return null

    beforeEach ->
        module "taigaComponents"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "require Color on Selector", () ->
        colorSelectorCtrl = controller "ColorSelectorCtrl"
        colorSelectorCtrl.colorList = ["#000000", "#123123"]
        colorSelectorCtrl.isColorRequired = false
        colorSelectorCtrl.checkIsColorRequired()
        expect(colorSelectorCtrl.colorList).to.be.eql(["#000000"])

    it "display Color Selector", () ->
        colorSelectorCtrl = controller "ColorSelectorCtrl"
        colorSelectorCtrl.toggleColorList()
        expect(colorSelectorCtrl.displayColorList).to.be.true

    it "on select Color", () ->
        colorSelectorCtrl = controller "ColorSelectorCtrl"
        colorSelectorCtrl.toggleColorList = sinon.stub()

        color = '#FFFFFF'

        colorSelectorCtrl.onSelectColor = sinon.spy()

        colorSelectorCtrl.onSelectDropdownColor(color)
        expect(colorSelectorCtrl.toggleColorList).have.been.called
        expect(colorSelectorCtrl.onSelectColor).to.have.been.calledWith({color: color})

    it "save on keydown Enter", () ->
        colorSelectorCtrl = controller "ColorSelectorCtrl"
        colorSelectorCtrl.onSelectDropdownColor = sinon.stub()

        event = {which: 13, preventDefault: sinon.stub()}
        customColor = "#fabada"

        colorSelectorCtrl.customColor = customColor

        colorSelectorCtrl.onKeyDown(event)
        expect(event.preventDefault).have.been.called
        expect(colorSelectorCtrl.onSelectDropdownColor).have.been.called
        expect(colorSelectorCtrl.onSelectDropdownColor).have.been.calledWith(customColor)
