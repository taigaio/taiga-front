describe "tgProfileTimelineItemTitle", ->
    mySvc = null
    mockTranslate = null
    timeline = event = type = null

    _mockTranslate = () ->
        _provide (provide) ->
            mockTranslate = {
                instant: sinon.stub()
            }

            provide.value "$translate", mockTranslate

    _provide = (callback) ->
        module ($provide) ->
            callback($provide)
            return null

    _mocks = () ->
        _mockTranslate()

    _inject = ->
        inject (_tgProfileTimelineItemTitle_) ->
            mySvc = _tgProfileTimelineItemTitle_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaProfile"
        _setup()

    it "title with username", () ->
        timeline = {
            data: {
                user: {
                    username: 'xx',
                    name: 'oo'
                }
            }
        }

        event = {}

        type = {
            key: 'TITLE_USER_NAME',
            translate_params: ['username']
        }

        mockTranslate.instant
            .withArgs('COMMON.SEE_USER_PROFILE', {username: timeline.data.user.username})
            .returns('user-param')

        usernamelink = sinon.match ((value) ->
            return value.username == '<a tg-nav="user-profile:username=vm.activity.user.username" title="user-param">oo</a>'
         ), "usernamelink"

        mockTranslate.instant
            .withArgs('TITLE_USER_NAME', usernamelink)
            .returns('title_ok')

        title = mySvc.getTitle(timeline, event, type)

        expect(title).to.be.equal("title_ok")

    it "title with a field name", () ->
        timeline = {
            data: {
                values_diff: {
                    status: {}
                }
            }
        }

        event = {}

        type = {
            key: 'TITLE_FIELD',
            translate_params: ['field_name']
        }

        mockTranslate.instant
            .withArgs('COMMON.FIELDS.STATUS')
            .returns('field-params')

        fieldparam = sinon.match ((value) ->
            return value.field_name == 'field-params'
         ), "fieldparam"

        mockTranslate.instant
            .withArgs('TITLE_FIELD', fieldparam)
            .returns('title_ok')


        title = mySvc.getTitle(timeline, event, type)

        expect(title).to.be.equal("title_ok")

    it "title with project name", () ->
        timeline = {
            data: {
                project: {
                    name: "project_name"
                }
            }
        }

        event = {}

        type = {
            key: 'TITLE_PROJECT',
            translate_params: ['project_name']
        }

        projectparam = sinon.match ((value) ->
            return value.project_name == '<a tg-nav="project:project=vm.activity.project.slug" title="project_name">project_name</a>'
         ), "projectparam"

        mockTranslate.instant
            .withArgs('TITLE_PROJECT', projectparam)
            .returns('title_ok')

        title = mySvc.getTitle(timeline, event, type)

        expect(title).to.be.equal("title_ok")

    it "title with sprint name", () ->
        timeline = {
            data: {
                milestone: {
                    name: "milestone_name"
                }
            }
        }

        event = {}

        type = {
            key: 'TITLE_MILESTONE',
            translate_params: ['sprint_name']
        }

        milestoneparam = sinon.match ((value) ->
            return value.sprint_name == '<a tg-nav="project-taskboard:project=vm.activity.project.slug,sprint=vm.activity.sprint.slug" title="milestone_name">milestone_name</a>'
         ), "milestoneparam"

        mockTranslate.instant
            .withArgs('TITLE_MILESTONE', milestoneparam)
            .returns('title_ok')

        title = mySvc.getTitle(timeline, event, type)

        expect(title).to.be.equal("title_ok")

    it "title with object", () ->
        timeline = {
            data: {
                issue: {
                    ref: '123',
                    subject: 'subject'
                }
            }
        }

        event = {
            obj: 'issue',
        }

        type = {
            key: 'TITLE_OBJ',
            translate_params: ['obj_name']
        }

        objparam = sinon.match ((value) ->
            return value.obj_name == '<a tg-nav="project-issues-detail:project=vm.activity.project.slug,ref=vm.activity.obj.ref" title="#123 subject">#123 subject</a>'
         ), "objparam"

        mockTranslate.instant
            .withArgs('TITLE_OBJ', objparam)
            .returns('title_ok')

        title = mySvc.getTitle(timeline, event, type)

        expect(title).to.be.equal("title_ok")

    it "title obj wiki", () ->
        timeline = {
            data: {
                wikipage: {
                    slug: 'slugwiki',
                }
            }
        }

        event = {
            obj: 'wikipage',
        }

        type = {
            key: 'TITLE_OBJ',
            translate_params: ['obj_name']
        }

        objparam = sinon.match ((value) ->
            return value.obj_name == '<a tg-nav="project-wiki-page:project=vm.activity.project.slug,slug=vm.activity.obj.slug" title="slugwiki">slugwiki</a>'
         ), "objparam"

        mockTranslate.instant
            .withArgs('TITLE_OBJ', objparam)
            .returns('title_ok')

        title = mySvc.getTitle(timeline, event, type)

        expect(title).to.be.equal("title_ok")

    it "title obj milestone", () ->
        timeline = {
            data: {
                milestone: {
                    name: 'milestone_name',
                }
            }
        }

        event = {
            obj: 'milestone',
        }

        type = {
            key: 'TITLE_OBJ',
            translate_params: ['obj_name']
        }

        objparam = sinon.match ((value) ->
            return value.obj_name == '<a tg-nav="project-taskboard:project=vm.activity.project.slug,sprint=vm.activity.obj.slug" title="milestone_name">milestone_name</a>'
         ), "objparam"

        mockTranslate.instant
            .withArgs('TITLE_OBJ', objparam)
            .returns('title_ok')

        title = mySvc.getTitle(timeline, event, type)

        expect(title).to.be.equal("title_ok")
