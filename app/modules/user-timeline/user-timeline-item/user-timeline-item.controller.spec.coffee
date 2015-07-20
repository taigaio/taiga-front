describe "UserTimelineItemController", ->
    controller = scope = provide = null
    timeline = event = null
    mockTgUserTimelineItemType = null
    mockTgUserTimelineItemTitle = null
    mockType = null

    _mockTgUserTimelineItemType = () ->
        mockTgUserTimelineItemType = {
            getType: sinon.stub()
        }

        mockType = {
            description: sinon.stub(),
            member: sinon.stub()
        }

        mockTgUserTimelineItemType.getType.withArgs(timeline).returns(mockType)

        provide.value "tgUserTimelineItemType", mockTgUserTimelineItemType

    _mockTgUserTimelineItemTitle = () ->
        mockTgUserTimelineItemTitle = {
            getTitle: sinon.stub()
        }

        mockTgUserTimelineItemTitle.getTitle.withArgs(timeline, event, mockType).returns("fakeTitle")

        provide.value "tgUserTimelineItemTitle", mockTgUserTimelineItemTitle

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgUserTimelineItemType()
            _mockTgUserTimelineItemTitle()

            return null

    _setup = () ->
        event = {
            section: 'issues',
            obj: 'issue',
            type: 'created'
        }

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
                    attachments: {
                        new: "fakeAttachment"
                    }
                }
            }
        })

        scope = {
            vm: {
                timeline: timeline
            }
        }

    beforeEach ->
        module "taigaUserTimeline"

        _setup()
        _mocks()

        inject ($controller) ->
            controller = $controller

    it "all activity fields filled", () ->
        timeline = scope.vm.timeline

        description = "fakeDescription"
        member = "fakeMember"

        mockType.description.returns(description)
        mockType.member.returns(member)

        myCtrl = controller("UserTimelineItem", {$scope: scope}, {timeline: timeline})

        expect(myCtrl.timeline.get('title_html')).to.be.equal("fakeTitle")
        expect(myCtrl.timeline.get('obj')).to.be.equal(myCtrl.timeline.getIn(["data", "issue"]))
        expect(myCtrl.timeline.get("description")).to.be.equal(description)
        expect(myCtrl.timeline.get("member")).to.be.equal(member)
        expect(myCtrl.timeline.get("attachments")).to.be.equal("fakeAttachment")
