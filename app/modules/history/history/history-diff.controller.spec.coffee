###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
