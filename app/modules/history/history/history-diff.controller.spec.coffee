###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
