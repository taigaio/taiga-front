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
# File: epics/dashboard/story-row/story-row.controller.spec.coffee
###

describe "StoryRowCtrl", ->
    controller = null

    beforeEach ->
        module "taigaEpics"

        inject ($controller) ->
            controller = $controller

    it "calculate percentage for some closed tasks", () ->
        data = {
            story: Immutable.fromJS(
                tasks: [
                    {is_closed: true},
                    {is_closed: true},
                    {is_closed: true},
                    {is_closed: false},
                    {is_closed: false},
                ]
            )
        }

        ctrl = controller "StoryRowCtrl", null, data
        expect(ctrl.percentage).to.be.equal("60%")

    it "calculate percentage for closed story", () ->
        data = {
            story: Immutable.fromJS(
                tasks: [
                    {is_closed: true},
                    {is_closed: true},
                    {is_closed: true},
                    {is_closed: false},
                    {is_closed: false},
                ]
                is_closed: true
            )
        }

        ctrl = controller "StoryRowCtrl", null, data
        expect(ctrl.percentage).to.be.equal("100%")

    it "calculate percentage for closed story", () ->
        data = {
            story: Immutable.fromJS(
                tasks: []
            )
        }

        ctrl = controller "StoryRowCtrl", null, data
        expect(ctrl.percentage).to.be.equal("0%")

