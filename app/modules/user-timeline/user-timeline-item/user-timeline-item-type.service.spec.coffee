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
