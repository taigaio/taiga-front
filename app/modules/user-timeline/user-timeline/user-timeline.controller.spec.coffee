describe "UserTimelineController", ->
    controller = scope = $q = provide = null

    mocks = {}

    mockUser = Immutable.fromJS({id: 3})

    _mockUserTimeline = () ->
        mocks.userTimelineService = {
            getProfileTimeline: sinon.stub(),
            getProjectTimeline: sinon.stub()
        }

        provide.value "tgUserTimelineService", mocks.userTimelineService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockUserTimeline()

            return null

    beforeEach ->
        module "taigaUserTimeline"
        _mocks()

        inject ($controller, _$q_) ->
            $q = _$q_
            controller = $controller

    it "timelineList should be an array", () ->
        myCtrl = controller "UserTimeline"
        expect(myCtrl.timelineList.toJS()).is.an("array")

    it "pagination starts at 1", () ->
        myCtrl = controller "UserTimeline"
        expect(myCtrl.page).to.be.equal(1)

    describe "load timeline", () ->
        timelineList = null

        beforeEach () ->
            timelineList = Immutable.fromJS([
                { fake: "fake"},
                { fake: "fake"},
                { fake: "fake"},
                { fake: "fake"}
            ])

        it "if is current user call getProfileTimeline and call timelineLoaded at the end", () ->
            myCtrl = controller "UserTimeline"
            myCtrl.currentUser = true
            myCtrl.user = mockUser

            myCtrl._timelineLoaded = sinon.spy()

            thenStub = sinon.stub()

            mocks.userTimelineService.getProfileTimeline = sinon.stub()
                .withArgs(mockUser.get("id"), myCtrl.page)
                .returns({
                    then: thenStub
                })

            myCtrl.loadTimeline()
            thenStub.callArgWith(0, timelineList)

        it "if not current user call getUserTimeline and call timelineLoaded at the end", () ->
            myCtrl = controller "UserTimeline"
            myCtrl.currentUser = false
            myCtrl.user = mockUser

            myCtrl._timelineLoaded = sinon.spy()

            thenStub = sinon.stub()

            mocks.userTimelineService.getUserTimeline = sinon.stub()
                .withArgs(mockUser.get("id"), myCtrl.page)
                .returns({
                    then: thenStub
                })

            myCtrl.loadTimeline()

            thenStub.callArgWith(0, timelineList)
            expect(myCtrl._timelineLoaded.withArgs(timelineList)).to.be.calledOnce

        it "the scrollDisabled variable must be true during the timeline load", () ->
            myCtrl = controller "UserTimeline"
            myCtrl.currentUser = true
            myCtrl.user = mockUser

            myCtrl._timelineLoaded = sinon.spy()

            thenStub = sinon.stub()

            mocks.userTimelineService.getProfileTimeline = sinon.stub()
                .withArgs(mockUser.get("id"), myCtrl.page)
                .returns({
                    then: thenStub
                })

            expect(myCtrl.scrollDisabled).to.be.false

            myCtrl.loadTimeline()

            expect(myCtrl.scrollDisabled).to.be.true

        it "disable scroll when no more content", () ->
            myCtrl = controller "UserTimeline"

            myCtrl.scrollDisabled = true

            myCtrl._timelineLoaded(Immutable.fromJS(['xx', 'ii']))

            expect(myCtrl.scrollDisabled).to.be.false

            myCtrl.scrollDisabled = true
            myCtrl._timelineLoaded(Immutable.fromJS([]))

            expect(myCtrl.scrollDisabled).to.be.true

        it "pagiantion increase one every call to loadTimeline", () ->
            myCtrl = controller "UserTimeline"

            expect(myCtrl.page).to.equal(1)

            myCtrl._timelineLoaded(timelineList)

            expect(myCtrl.page).to.equal(2)

        it "concat timeline list", () ->
            myCtrl = controller "UserTimeline"

            myCtrl._timelineLoaded(timelineList)
            myCtrl._timelineLoaded(timelineList)
            expect(myCtrl.timelineList.size).to.be.eql(8)

        it "project timeline items", () ->
            myCtrl = controller "UserTimeline"
            myCtrl.user = mockUser
            myCtrl.projectId = 4

            thenStub = sinon.stub()

            mocks.userTimelineService.getProjectTimeline = sinon.stub()
                .withArgs(4, myCtrl.page)
                .returns({
                    then: thenStub
                })

            myCtrl.loadTimeline()

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.timelineList.size).to.be.eql(4)
            expect(myCtrl.page).to.equal(2)
