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

        timeline =  {
            event_type: 'issues.issue.created',
            data: {
                user: 'user_fake',
                project: 'project_fake',
                milestone: 'milestone_fake',
                created: new Date().getTime(),
                values_diff: {}
            }
        }

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

    it "basic activity fields filled", () ->
        timeline = scope.vm.timeline
        timeline_immutable = Immutable.fromJS(timeline)

        myCtrl = controller("UserTimelineItem", {$scope: scope}, {timeline: timeline_immutable})

        expect(myCtrl.activity.user).to.be.equal(timeline.data.user)
        expect(myCtrl.activity.project).to.be.equal(timeline.data.project)
        expect(myCtrl.activity.sprint).to.be.equal(timeline.data.milestone)
        expect(myCtrl.activity.title).to.be.equal("fakeTitle")
        expect(myCtrl.activity.created_formated).to.have.length.above(1)

    it "all activity fields filled", () ->
        timeline = scope.vm.timeline

        attachment = "fakeAttachment"
        timeline.data.values_diff.attachments = {
            new: attachment
        }

        description = "fakeDescription"
        member = "fakeMember"

        mockType.description.withArgs(timeline).returns(description)
        mockType.member.withArgs(timeline).returns(member)

        timeline_immutable = Immutable.fromJS(timeline)

        myCtrl = controller("UserTimelineItem", {$scope: scope}, {timeline: timeline_immutable})

        expect(myCtrl.activity.description).to.be.an('object') # $sce.trustAsHtml
        expect(myCtrl.activity.member).to.be.equal(member)
        expect(myCtrl.activity.attachments).to.be.equal(attachment)
