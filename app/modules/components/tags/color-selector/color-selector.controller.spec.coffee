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
# File: color-selector.controller.spec.coffee
###

describe "ColorSelector", ->
    provide = null
    controller = null
    colorSelectorCtrl = null
    mocks = {}

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            return null

    beforeEach ->
        module "taigaCommon"

        _mocks()

        inject ($controller) ->
            controller = $controller

        colorSelectorCtrl = controller "ColorSelectorCtrl"
        colorSelectorCtrl.colorList = [
            '#fce94f',
            '#edd400',
            '#c4a000',
        ]
        colorSelectorCtrl.displaycolorList = false

    it "display Color Selector", () ->
        colorSelectorCtrl.toggleColorList()
        expect(colorSelectorCtrl.displaycolorList).to.be.true

    it "on select Color", () ->
        colorSelectorCtrl.toggleColorList = sinon.stub()

        color = '#FFFFFF'

        colorSelectorCtrl.onSelectColor = sinon.spy()

        colorSelectorCtrl.onSelectDropdownColor(color)
        expect(colorSelectorCtrl.toggleColorList).have.been.called
        expect(colorSelectorCtrl.onSelectColor).to.have.been.calledWith({color: color})
