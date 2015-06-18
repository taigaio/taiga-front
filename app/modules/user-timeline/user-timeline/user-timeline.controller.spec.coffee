describe "UserTimelineController", ->
    controller = scope = $q = provide = $rootScope = null

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

        inject ($controller, _$q_, _$rootScope_) ->
            $q = _$q_
            controller = $controller
            $rootScope = _$rootScope_

    it "timelineList should be an array", () ->
        $scope = $rootScope.$new();

        mocks.userTimelineService.getUserTimeline = sinon.stub().returns(true)

        myCtrl = controller("UserTimeline", $scope, {
            user: Immutable.Map({id: 2})
        })

        expect(myCtrl.timelineList.toJS()).is.an("array")

    describe "init timeline", () ->
        it "project timeline sequence", () ->
            mocks.userTimelineService.getProjectTimeline = sinon.stub().withArgs(4).returns(true)

            $scope = $rootScope.$new();

            myCtrl = controller("UserTimeline", $scope, {
                projectId: 4
            })

            expect(myCtrl.timeline).to.be.true

        it "currentUser timeline sequence", () ->
            mocks.userTimelineService.getProfileTimeline = sinon.stub().withArgs(2).returns(true)

            $scope = $rootScope.$new();

            myCtrl = controller("UserTimeline", $scope, {
                currentUser: true,
                user: Immutable.Map({id: 2})
            })

            expect(myCtrl.timeline).to.be.true

        it "currentUser timeline sequence", () ->
            mocks.userTimelineService.getUserTimeline = sinon.stub().withArgs(2).returns(true)

            $scope = $rootScope.$new();

            myCtrl = controller("UserTimeline", $scope, {
                user: Immutable.Map({id: 2})
            })

            expect(myCtrl.timeline).to.be.true

    describe "load timeline", () ->
        myCtrl = null

        beforeEach () ->
            mocks.userTimelineService.getUserTimeline = sinon.stub().returns({})
            $scope = $rootScope.$new();
            myCtrl = controller("UserTimeline", $scope, {
                user: Immutable.Map({id: 2})
            })

        it "enable scroll on loadTimeline if there are more pages", (done) ->
            response = Immutable.Map({
                items: [1, 2, 3],
                next: true
            })

            myCtrl.timeline.next = sinon.stub().promise()
            myCtrl.timeline.next.resolve(response)

            expect(myCtrl.scrollDisabled).to.be.false

            myCtrl.loadTimeline().then () ->
                expect(myCtrl.scrollDisabled).to.be.false

                done()

        it "disable scroll on loadTimeline if there are more pages", (done) ->
            response = Immutable.Map({
                items: [1, 2, 3],
                next: false
            })

            myCtrl.timeline.next = sinon.stub().promise()
            myCtrl.timeline.next.resolve(response)

            expect(myCtrl.scrollDisabled).to.be.false

            myCtrl.loadTimeline().then () ->
                expect(myCtrl.scrollDisabled).to.be.true

                done()

        it "concat response data", (done) ->
            response = Immutable.Map({
                items: [1, 2, 3],
                next: false
            })

            myCtrl.timelineList = Immutable.List([1, 2])
            myCtrl.timeline.next = sinon.stub().promise()
            myCtrl.timeline.next.resolve(response)

            expect(myCtrl.scrollDisabled).to.be.false

            myCtrl.loadTimeline().then () ->
                expect(myCtrl.timelineList.size).to.be.equal(5)

                done()
