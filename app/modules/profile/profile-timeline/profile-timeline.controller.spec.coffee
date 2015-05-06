describe "ProfileTimelineController", ->
    myCtrl = scope = $q = provide = null

    mocks = {}

    mockUser = {id: 3}

    _mockProfileTimeline = () ->
        mocks.profileTimelineService = {
            getTimeline: sinon.stub()
        }

        provide.value "tgProfileTimelineService", mocks.profileTimelineService

    _mockTgAuth = () ->
        provide.value "$tgAuth", {
            getUser: () ->
                return mockUser
        }

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockProfileTimeline()
            _mockTgAuth()

            return null


    beforeEach ->
        module "taigaProfile"
        _mocks()

        inject ($controller, _$q_) ->
            $q = _$q_
            myCtrl = $controller "ProfileTimeline"

    it "timelineList should be an array", () ->
        expect(myCtrl.timelineList.toJS()).is.an("array")

    it "pagination starts at 1", () ->
        expect(myCtrl.page).to.be.equal(1)

    describe "load timeline", () ->
        thenStub = timelineList = null

        beforeEach () ->
            timelineList = Immutable.fromJS([
                { fake: "fake"},
                { fake: "fake"},
                { fake: "fake"},
                { fake: "fake"}
            ])

            thenStub = sinon.stub()

            profileStub = sinon.stub()
                .withArgs(mockUser.id, myCtrl.page)
                .returns({
                    then: thenStub
                })

            mocks.profileTimelineService.getTimeline = profileStub

        it "the loadingData variable must be true during the timeline load", () ->
            expect(myCtrl.loadingData).to.be.false

            myCtrl.loadTimeline()

            expect(myCtrl.loadingData).to.be.true

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.loadingData).to.be.false

        it "pagiantion increase one every call to loadTimeline", () ->
            expect(myCtrl.page).to.equal(1)

            myCtrl.loadTimeline()

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.page).to.equal(2)

        it "timeline items", () ->
            myCtrl.loadTimeline()

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.timelineList.size).to.be.eql(4)
