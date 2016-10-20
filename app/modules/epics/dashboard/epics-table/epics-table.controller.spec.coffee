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
# File: epic-row.controller.spec.coffee
###

describe "EpicTable", ->
    epicTableCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }
        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgEpicsService = () ->
        mocks.tgEpicsService = {
            createEpic: sinon.stub()
            nextPage: sinon.stub()
        }
        provide.value "tgEpicsService", mocks.tgEpicsService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgConfirm()
            _mockTgEpicsService()
            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "toggle table options", () ->
        epicTableCtrl = controller "EpicsTableCtrl"
        epicTableCtrl.displayOptions = true
        epicTableCtrl.toggleEpicTableOptions()
        expect(epicTableCtrl.displayOptions).to.be.false

    it "next page", () ->
        epicTableCtrl = controller "EpicsTableCtrl"

        epicTableCtrl.nextPage()

        expect(mocks.tgEpicsService.nextPage).to.have.been.calledOnce
