###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: user-timeline/user-timeline/user-timeline.service.spec.coffee
###

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

    _mockTgUserTimelineItemType = () ->
        mocks.userTimelineItemType = {
            getType: sinon.stub()
        }

        mocks.getType = {
            description: sinon.stub(),
            member: sinon.stub()
        }

        mocks.userTimelineItemType.getType.returns(mocks.getType)

        provide.value "tgUserTimelineItemType", mocks.userTimelineItemType

    _mockTgUserTimelineItemTitle = () ->
        mocks.userTimelineItemTitle = {
            getTitle: sinon.stub()
        }

        provide.value "tgUserTimelineItemTitle", mocks.userTimelineItemTitle

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()
            _mockUserTimelinePaginationSequence()
            _mockTgUserTimelineItemType()
            _mockTgUserTimelineItemTitle()

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
                expect(res.get('data').size).to.be.equal(13)

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
                expect(res.get('data').size).to.be.equal(13)

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
                expect(res.get('data').size).to.be.equal(13)

                items = config.filter(res.get('data'))
                expect(items.size).to.be.equal(5)

                return true

        result = userTimelineService.getProjectTimeline(userId)
        expect(result).to.be.eventually.true

    it "all timeline extra fields filled", () ->
        timeline =  Immutable.fromJS({
            event_type: 'issues.issue.created',
            data: {
                user: 'user_fake',
                project: 'project_fake',
                milestone: 'milestone_fake',
                created: new Date().getTime(),
                issue: {
                    id: 2
                },
                value_diff: {
                    key: 'attachments',
                    value: {
                        new: "fakeAttachment"
                    }
                }
            }
        })

        mocks.userTimelineItemTitle.getTitle.returns("fakeTitle")
        mocks.getType.description.returns("fakeDescription")
        mocks.getType.member.returns("fakeMember")

        timelineEntry = userTimelineService._addEntyAttributes(timeline)

        expect(timelineEntry.get('title_html')).to.be.equal("fakeTitle")
        expect(timelineEntry.get('obj')).to.be.equal(timelineEntry.getIn(["data", "issue"]))
        expect(timelineEntry.get("description")).to.be.equal("fakeDescription")
        expect(timelineEntry.get("member")).to.be.equal("fakeMember")
        expect(timelineEntry.get("attachments")).to.be.equal("fakeAttachment")
