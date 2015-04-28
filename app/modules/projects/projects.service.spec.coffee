describe "tgProjects", ->
    projectsService = provide = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.projects = {
            listByMember: sinon.stub()
        }

        mocks.thenStub = sinon.stub()
        mocks.resources.projects.listByMember.withArgs(10).returns({
            then: mocks.thenStub
        })

        provide.value "$tgResources", mocks.resources

    _mockRootScope = () ->
        provide.value "$rootScope", {user: {id: 10}}

    _mockProjectUrl = () ->
        mocks.projectUrl = {get: sinon.stub()}

        mocks.projectUrl.get = (project) ->
            return "url-" + project.id

        provide.value "$projectUrl", mocks.projectUrl

    _mockLightboxFactory = () ->
        mocks.lightboxFactory = {
            create: sinon.stub()
        }

        provide.value "tgLightboxFactory", mocks.lightboxFactory

    _inject = (callback) ->
        inject (_tgProjects_) ->
            projectsService = _tgProjects_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()
            _mockRootScope()
            _mockProjectUrl()
            _mockLightboxFactory()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaProjects"
        _setup()
        _inject()

    describe "fetch items", ->
        projects = []

        beforeEach ->
            projects = [
                {"id": 1},
                {"id": 2},
                {"id": 3},
                {"id": 4},
                {"id": 5},
                {"id": 6},
                {"id": 7},
                {"id": 8},
                {"id": 9},
                {"id": 10},
                {"id": 11},
                {"id": 12},
            ]

        it "all & recents filled", () ->
            mocks.thenStub.callArg(0, projects)

            expect(projectsService.projects.get("all").toJS()).to.be.eql(projects)
            expect(projectsService.projects.get("recents").toJS()).to.be.eql(projects.slice(0, 10))

        it "_inProgress change to false when tgResources end", () ->
            expect(projectsService._inProgress).to.be.true

            mocks.thenStub.callArg(0, projects)

            expect(projectsService._inProgress).to.be.false

        it "_inProgress prevent new ajax calls", () ->
            projectsService.fetchProjects()
            projectsService.fetchProjects()

            mocks.thenStub.callArg(0, projects)

            expect(mocks.resources.projects.listByMember).have.been.calledOnce

        it "group projects by id", () ->
            mocks.thenStub.callArg(0, projects)

            expect(projectsService.projectsById.size).to.be.equal(12)
            expect(projectsService.projectsById.toJS()[1].id).to.be.equal(projects[0].id)

        it "add urls in the project object", () ->
            mocks.thenStub.callArg(0, projects)

            expect(projectsService.projectsById.toJS()[1].url).to.be.equal("url-1")
            expect(projectsService.projects.get("all").toJS()[0].url).to.be.equal("url-1")
            expect(projectsService.projects.get("recents").toJS()[0].url).to.be.equal("url-1")

    it "newProject, create the wizard lightbox", () ->
        projectsService.newProject()

        expect(mocks.lightboxFactory.create).to.have.been.calledWith("tg-lb-create-project", {
            "class": "wizard-create-project"
        })

    it "bulkUpdateProjectsOrder and then fetch projects again", () ->
        projects_order = [
            {"id": 8},
            {"id": 2},
            {"id": 3},
            {"id": 9},
            {"id": 1},
            {"id": 4},
            {"id": 10},
            {"id": 5},
            {"id": 6},
            {"id": 7},
            {"id": 11},
            {"id": 12},
        ]

        thenStub = sinon.stub()

        mocks.resources.projects.bulkUpdateOrder = sinon.stub()
        mocks.resources.projects.bulkUpdateOrder.withArgs(projects_order).returns({
            then: thenStub
        })

        projectsService.fetchProjects = sinon.stub()

        projectsService.bulkUpdateProjectsOrder(projects_order)

        thenStub.callArg(0)

        expect(projectsService.fetchProjects).to.have.been.calledOnce
