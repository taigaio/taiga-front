describe "tgProfileTimelineService", ->
    provide = null
    $q = null
    $rootScope = null
    profileTimelineService = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.timeline = {
            profile: sinon.stub()
        }

        provide.value "$tgResources", mocks.resources

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()

            return null

    _setup = ->
        _mocks()

    _inject = (callback) ->
        inject (_tgProfileTimelineService_, _$q_, _$rootScope_) ->
            profileTimelineService = _tgProfileTimelineService_
            $q = _$q_
            $rootScope = _$rootScope_
            callback() if callback

    beforeEach ->
        module "taigaProjects"
        _setup()
        _inject()

    it "filter invalid timeline items", (done) ->
        valid_items = {
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
                },
                { # invalid item
                    data: {
                        values_diff: {
                            attachments: {
                                new: []
                            }
                        }
                    }
                },
                { # valid item
                    data: {
                        values_diff: {
                            attachments: {
                                new: [1, 2]
                            }
                        }
                    }
                }
            ]
        }

        userId = 3
        page = 2

        mocks.resources.timeline.profile = (_userId_, _page_) ->
            expect(_userId_).to.be.equal(userId)
            expect(_page_).to.be.equal(page)

            return $q (resolve, reject) ->
                resolve(valid_items)

        profileTimelineService.getTimeline(userId, page)
            .then (_items_) ->
                items = _items_.toJS()

                expect(items[0]).to.be.eql(valid_items.data[0])
                expect(items[1]).to.be.eql(valid_items.data[3])
                expect(items[2]).to.be.eql(valid_items.data[5])

                done()

        $rootScope.$apply()
