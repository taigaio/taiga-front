describe "tgUserTimelineService", ->
    provide = null
    userTimelineService = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.users = {
            getTimeline: sinon.stub(),
            getProfileTimeline: sinon.stub(),
            getUserTimeline: sinon.stub()
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

        response = Immutable.fromJS({
            data: valid_items
        })

        mocks.resources.users.getProfileTimeline.withArgs(userId).promise().resolve(response)

        mocks.userTimelinePaginationSequence.generate = (config) ->
            return config.fetch().then (res) ->
                expect(res.get('data').size).to.be.equal(14)

                items = config.filter(res.get('data'))
                expect(items.size).to.be.equal(5)

                return true

        result = userTimelineService.getProfileTimeline(userId)

        return expect(result).to.be.eventually.true

    it "filter invalid user timeline items", () ->
        userId = 3
        page = 2

        response = Immutable.fromJS({
            data: valid_items
        })

        mocks.resources.users.getUserTimeline.withArgs(userId).promise().resolve(response)

        mocks.userTimelinePaginationSequence.generate = (config) ->
            return config.fetch().then (res) ->
                expect(res.get('data').size).to.be.equal(14)

                items = config.filter(res.get('data'))
                expect(items.size).to.be.equal(5)

                return true

        result = userTimelineService.getUserTimeline(userId)

        return expect(result).to.be.eventually.true

    it "filter invalid project timeline items", () ->
        userId = 3
        page = 2

        response = Immutable.fromJS({
            data: valid_items
        })

        mocks.resources.projects.getTimeline.withArgs(userId).promise().resolve(response)

        mocks.userTimelinePaginationSequence.generate = (config) ->
            return config.fetch().then (res) ->
                expect(res.get('data').size).to.be.equal(14)

                items = config.filter(res.get('data'))
                expect(items.size).to.be.equal(5)

                return true

        result = userTimelineService.getProjectTimeline(userId)
        expect(result).to.be.eventually.true
