describe "ProfileTimelineController", ->
    myCtrl = scope = $q = provide = null

    mockUser = {id: 3}

    _mockTgResources = () ->
        provide.value "$tgResources", {
            timeline: {}
        }

    _mockTgAuth = () ->
        provide.value "$tgAuth", {
            getUser: () ->
                return mockUser
        }

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgResources()
            _mockTgAuth()

            return null


    beforeEach ->
        module "taigaProfile"
        _mocks()

        inject ($controller, _$q_) ->
            $q = _$q_
            myCtrl = $controller "ProfileTimeline"

    it "timelineList should be an array", () ->
        expect(myCtrl.timelineList).is.an("array")


    it "pagination starts at 1", () ->
        expect(myCtrl.pagination.page).to.be.equal(1)

    describe "load timeline", () ->
        thenStub = timelineList = null

        beforeEach () ->
            timelineList = {
                data: [
                    { # valid item
                        data: {
                            values_diff: {
                                "status": "xx",
                                "subject": "xx"
                            }
                        }
                    },
                    { # invalid item
                        data: {
                            values_diff: {
                                "fake": "xx"
                            }
                        }
                    },
                    { # invalid item
                        data: {
                            values_diff: {
                                "fake2": "xx"
                            }
                        }
                    },
                    { # valid item
                        data: {
                            values_diff: {
                                "fake2": "xx",
                                "milestone": "xx"
                            }
                        }
                    }
                ]
            }

            thenStub = sinon.stub()

            profileStub = sinon.stub()
                .withArgs(mockUser.id, myCtrl.pagination)
                .returns({
                    then: thenStub
                })

            myCtrl.rs.timeline.profile = profileStub

        it "the loadingData variable must be true during the timeline load", () ->
            expect(myCtrl.loadingData).to.be.false

            myCtrl.loadTimeline()

            expect(myCtrl.loadingData).to.be.true

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.loadingData).to.be.false

        it "pagiantion increase one every call to loadTimeline", () ->
            expect(myCtrl.pagination.page).to.equal(1)

            myCtrl.loadTimeline()

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.pagination.page).to.equal(2)

        it "filter the invalid timeline items", () ->
            myCtrl.loadTimeline()

            thenStub.callArgWith(0, timelineList)

            expect(myCtrl.timelineList[0]).to.be.equal(timelineList.data[0])
            expect(myCtrl.timelineList[1]).to.be.equal(timelineList.data[3])
