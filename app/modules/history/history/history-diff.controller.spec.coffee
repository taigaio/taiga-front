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
# File: history/history/history-diff.controller.spec.coffee
###

describe "ActivitiesDiffController", ->
    provide = null
    controller = null
    mocks = {}

    beforeEach ->
        module "taigaHistory"

        inject ($controller) ->
            controller = $controller

    it "Check diff between tags", () ->
        activitiesDiffCtrl = controller "ActivitiesDiffCtrl"

        activitiesDiffCtrl.type = "tags"

        activitiesDiffCtrl.diff = [
            ["architecto", "perspiciatis", "testafo"],
            ["architecto", "perspiciatis", "testafo", "fasto"]
        ]

        activitiesDiffCtrl.diffTags()
        expect(activitiesDiffCtrl.diffRemoveTags).to.be.equal('')
        expect(activitiesDiffCtrl.diffAddTags).to.be.equal('fasto')
