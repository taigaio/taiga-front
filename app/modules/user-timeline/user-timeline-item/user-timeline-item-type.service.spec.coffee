###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
