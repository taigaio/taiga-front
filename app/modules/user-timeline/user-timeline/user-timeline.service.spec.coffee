describe "tgUserTimelineService", ->
    provide = null
    userTimelineService = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.users = {
            getTimeline: sinon.stub()
        }

        mocks.resources.projects = {
            getTimeline: sinon.stub()
        }

        provide.value "tgResources", mocks.resources

    _mockUserTimelinePaginationSequence = () ->
        mocks.userTimelinePaginationSequence = {}

        provide.value "tgUserTimelinePaginationSequenceService", mocks.userTimelinePaginationSequence

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()
            _mockUserTimelinePaginationSequence()

            return null

    _setup = ->
        _mocks()

    _inject = (callback) ->
        inject (_tgUserTimelineService_) ->
            userTimelineService = _tgUserTimelineService_
            callback() if callback

    beforeEach ->
        module "taigaUserTimeline"
        _setup()
        _inject()

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
            },
            { # invalid item
                event_type: "xx.project.change",
                data: {
                    values_diff: {
                        "name": "xx"
                    }
                }
            },
            { # invalid item
                event_type: "xx.us.change",
                data: {
                    comment_deleted: true,
                    values_diff: {
                        "status": "xx",
                        "subject": "xx"
                    }
                }
            },
            { # valid item
                event_type: "xx.task.change",
                data: {
                    values_diff: {
                        "name": "xx"
                    }
                }
            },
            { # invalid item
                event_type: "xx.task.change",
                data: {
                    values_diff: {
                        "milestone": "xx"
                    }
                }
            }
        ]

    it "filter invalid profile timeline items", () ->
        userId = 3
        page = 2

        mocks.resources.users.getProfileTimeline = (_userId_) ->
            expect(_userId_).to.be.equal(userId)

            return Immutable.fromJS(valid_items)

        mocks.userTimelinePaginationSequence.generate = (config) ->
            all = config.fetch()
            expect(all.size).to.be.equal(11)

            items = config.filter(all).toJS()
            expect(items).to.have.length(4)
            expect(items[0]).to.be.eql(valid_items[0])
            expect(items[1]).to.be.eql(valid_items[3])
            expect(items[2]).to.be.eql(valid_items[5])
            expect(items[3]).to.be.eql(valid_items[9])

            return true

        result = userTimelineService.getProfileTimeline(userId)
        expect(result).to.be.true

    it "filter invalid user timeline items", () ->
        userId = 3
        page = 2

        mocks.resources.users.getUserTimeline = (_userId_) ->
            expect(_userId_).to.be.equal(userId)

            return Immutable.fromJS(valid_items)

        mocks.userTimelinePaginationSequence.generate = (config) ->
            all = config.fetch()
            expect(all.size).to.be.equal(11)

            items = config.filter(all).toJS()
            expect(items).to.have.length(4)
            expect(items[0]).to.be.eql(valid_items[0])
            expect(items[1]).to.be.eql(valid_items[3])
            expect(items[2]).to.be.eql(valid_items[5])
            expect(items[3]).to.be.eql(valid_items[9])

            return true

        result = userTimelineService.getUserTimeline(userId)
        expect(result).to.be.true

    it "filter invalid user timeline items", () ->
        userId = 3
        page = 2

        mocks.resources.projects.getTimeline = (_userId_) ->
            expect(_userId_).to.be.equal(userId)

            return Immutable.fromJS(valid_items)

        mocks.userTimelinePaginationSequence.generate = (config) ->
            all = config.fetch()
            expect(all.size).to.be.equal(11)

            items = config.filter(all).toJS()
            expect(items).to.have.length(4)
            expect(items[0]).to.be.eql(valid_items[0])
            expect(items[1]).to.be.eql(valid_items[3])
            expect(items[2]).to.be.eql(valid_items[5])
            expect(items[3]).to.be.eql(valid_items[9])

            return true

        result = userTimelineService.getProjectTimeline(userId)
        expect(result).to.be.true
