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

    _mocks = () ->
        module ($provide) ->
            provide = $provide

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

    it "can edit", () ->
        data = {
            project: {
                my_permissions: [
                    'modify_epic'
                ]
            }
        }
        epicTableCtrl = controller "EpicsTableCtrl", null, data
        expect(epicTableCtrl.permissions.canEdit).to.be.true

    it "can NOT edit", () ->
        data = {
            project: {
                my_permissions: [
                    'modify_us'
                ]
            }
        }
        epicTableCtrl = controller "EpicsTableCtrl", null, data
        expect(epicTableCtrl.permissions.canEdit).to.be.false
