###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgUserTimelineItemType", ->
    mySvc = null

    _provide = (callback) ->
        module ($provide) ->
            callback($provide)
            return null

    _inject = ->
        inject (_tgUserTimelineItemType_) ->
            mySvc = _tgUserTimelineItemType_

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaUserTimeline"
        _setup()

    it "get the timeline type", () ->
        timeline = {
            data: {}
        }

        event = {
            obj: 'membership'
        }

        type = mySvc.getType(timeline, event)

        expect(type.key).to.be.equal("TIMELINE.NEW_MEMBER")
