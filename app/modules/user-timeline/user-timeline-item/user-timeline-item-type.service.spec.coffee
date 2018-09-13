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
# File: user-timeline/user-timeline-item/user-timeline-item-type.service.spec.coffee
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
