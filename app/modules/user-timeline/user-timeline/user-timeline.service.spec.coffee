describe "tgUserTimelineService", ->
    provide = null
    $q = null
    $rootScope = null
    userTimelineService = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.users = {
            getTimeline: sinon.stub()
        }

        provide.value "tgResources", mocks.resources

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()

            return null

    _setup = ->
        _mocks()

    _inject = (callback) ->
        inject (_tgUserTimelineService_, _$q_, _$rootScope_) ->
            userTimelineService = _tgUserTimelineService_
            $q = _$q_
            $rootScope = _$rootScope_
            callback() if callback

    beforeEach ->
        module "taigaUserTimeline"
        _setup()
        _inject()

    it "filter invalid timeline items", (done) ->
        valid_items = [
                { # valid item
                    event_type: "xx.tt.create",
                    data: {
                        values_diff: {
                            "status": "xx",
                            "subject": "xx"
                        }
                    }
                },
                { # invalid item
                    event_type: "xx.tt.create",
                    data: {
                        values_diff: {
                            "fake": "xx"
                        }
                    }
                },
                { # invalid item
                    event_type: "xx.tt.create",
                    data: {
                        values_diff: {
                            "fake2": "xx"
                        }
                    }
                },
                { # valid item
                    event_type: "xx.tt.create",
                    data: {
                        values_diff: {
                            "fake2": "xx",
                            "milestone": "xx"
                        }
                    }
                },
                { # invalid item
                    event_type: "xx.tt.create",
                    data: {
                        values_diff: {
                            attachments: {
                                new: []
                            }
                        }
                    }
                },
                { # valid item
                    event_type: "xx.tt.create",
                    data: {
                        values_diff: {
                            attachments: {
                                new: [1, 2]
                            }
                        }
                    }
                },
                { # invalid item
                    event_type: "xx.tt.delete",
                    data: {
                        values_diff: {
                            attachments: {
                                new: [1, 2]
                            }
                        }
                    }
                }
            ]

        userId = 3
        page = 2

        mocks.resources.users.getTimeline = (_userId_, _page_) ->
            expect(_userId_).to.be.equal(userId)
            expect(_page_).to.be.equal(page)

            return $q (resolve, reject) ->
                resolve(Immutable.fromJS(valid_items))

        userTimelineService.getTimeline(userId, page)
            .then (_items_) ->
                items = _items_.toJS()

                expect(items).to.have.length(3)
                expect(items[0]).to.be.eql(valid_items[0])
                expect(items[1]).to.be.eql(valid_items[3])
                expect(items[2]).to.be.eql(valid_items[5])

                done()

        $rootScope.$apply()
