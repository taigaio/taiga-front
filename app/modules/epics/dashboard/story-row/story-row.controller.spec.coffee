###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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

