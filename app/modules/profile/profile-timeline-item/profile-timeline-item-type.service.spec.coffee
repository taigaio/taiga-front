describe "tgProfileTimelineItemType", ->
    mySvc = null

    _provide = (callback) ->
        module ($provide) ->
            callback($provide)
            return null

    _inject = ->
        inject (_tgProfileTimelineItemType_) ->
            mySvc = _tgProfileTimelineItemType_

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaProfile"
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
