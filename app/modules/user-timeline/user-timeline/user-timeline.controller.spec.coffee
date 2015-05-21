describe "UserTimelineController", ->
    controller = scope = $q = provide = null

    mocks = {}

    mockUser = {id: 3}

    _mockUserTimeline = () ->
        mocks.userTimelineService = {
            getTimeline: sinon.stub(),
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

        it "the scrollDisabled variable must be true during the timeline load", () ->
            myCtrl = controller "UserTimeline"
            myCtrl.userId = mockUser.id

            thenStub = sinon.stub()

            mocks.userTimelineService.getTimeline = sinon.stub()
                .withArgs(mockUser.id, myCtrl.page)
                .returns({
                    then: thenStub
                })

            expect(myCtrl.scrollDisabled).to.be.false

            myCtrl.loadTimeline()

            expect(myCtrl.scrollDisabled).to.be.true

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.scrollDisabled).to.be.false

        it "disable scroll when no more content", () ->
            emptyTimelineList = Immutable.fromJS([])

            myCtrl = controller "UserTimeline"
            myCtrl.userId = mockUser.id

            thenStub = sinon.stub()

            mocks.userTimelineService.getTimeline = sinon.stub()
                .withArgs(mockUser.id, myCtrl.page)
                .returns({
                    then: thenStub
                })

            expect(myCtrl.scrollDisabled).to.be.false

            myCtrl.loadTimeline()

            expect(myCtrl.scrollDisabled).to.be.true

            thenStub.callArgWith(0, emptyTimelineList)

            expect(myCtrl.scrollDisabled).to.be.true

        it "pagiantion increase one every call to loadTimeline", () ->
            myCtrl = controller "UserTimeline"
            myCtrl.userId = mockUser.id

            thenStub = sinon.stub()

            mocks.userTimelineService.getTimeline = sinon.stub()
                .withArgs(mockUser.id, myCtrl.page)
                .returns({
                    then: thenStub
                })

            expect(myCtrl.page).to.equal(1)

            myCtrl.loadTimeline()

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.page).to.equal(2)

        it "timeline items", () ->
            myCtrl = controller "UserTimeline"
            myCtrl.userId = mockUser.id

            thenStub = sinon.stub()

            mocks.userTimelineService.getTimeline = sinon.stub()
                .withArgs(mockUser.id, myCtrl.page)
                .returns({
                    then: thenStub
                })

            myCtrl.loadTimeline()

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.timelineList.size).to.be.eql(4)

        it "project timeline items", () ->
            myCtrl = controller "UserTimeline"
            myCtrl.userId = mockUser.id
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
