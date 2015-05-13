describe "tgProjects", ->
    projectsService = provide = $rootScope = null
    $q = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.projects = {}

        mocks.resources.projects.getProjectsByUserId = () ->
            return $q (resolve) ->
                resolve(Immutable.fromJS([]))

        provide.value "tgResources", mocks.resources

    _mockAuthService = () ->
        mocks.auth = {userData: Immutable.fromJS({id: 10})}

        provide.value "$tgAuth", mocks.auth

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
        inject (_$q_, _$rootScope_) ->
            $q = _$q_
            $rootScope = _$rootScope_
            callback() if callback

    _injectService = (callback) ->
        inject (_tgProjectsService_) ->
            projectsService = _tgProjectsService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()
            _mockProjectUrl()
            _mockLightboxFactory()
            _mockAuthService()

            return null

    beforeEach ->
        module "taigaProjects"
        _mocks()
        _inject()

    describe "fetch items", ->
        projects = []

        beforeEach ->
            projects = [
                {"id": 1, url: 'url-1', tags: ['xx', 'yy', 'aa'], tags_colors: {xx: "red", yy: "blue", aa: "white"}, colorized_tags: [{name: 'aa', color: 'white'}, {name: 'xx', color: 'red'}, {name: 'yy', color: 'blue'}]},
                {"id": 2, url: 'url-2'},
                {"id": 3, url: 'url-3'},
                {"id": 4, url: 'url-4'},
                {"id": 5, url: 'url-5'},
                {"id": 6, url: 'url-6'},
                {"id": 7, url: 'url-7'},
                {"id": 8, url: 'url-8'},
                {"id": 9, url: 'url-9'},
                {"id": 10, url: 'url-10'},
                {"id": 11, url: 'url-11'},
                {"id": 12, url: 'url-12'}
            ]

            mocks.resources.projects.getProjectsByUserId = () ->
                return $q (resolve) ->
                    resolve(Immutable.fromJS(projects))

            _injectService()

        it "all & recents filled", () ->
            projectsService.fetchProjects()
            $rootScope.$digest()

            expect(projectsService.currentUserProjects.get("all").toJS()).to.be.eql(projects)
            expect(projectsService.currentUserProjects.get("recents").toJS()).to.be.eql(projects.slice(0, 10))

        it "_inProgress change to false when tgResources end", () ->
            expect(projectsService._inProgress).to.be.true

            $rootScope.$digest()

            expect(projectsService._inProgress).to.be.false

        it "group projects by id", () ->
            $rootScope.$digest()

            expect(projectsService.currentUserProjectsById.size).to.be.equal(12)
            expect(projectsService.currentUserProjectsById.toJS()[1].id).to.be.equal(projects[0].id)

        it "add urls in the project object", () ->
            $rootScope.$digest()

            expect(projectsService.currentUserProjectsById.toJS()[1].url).to.be.equal("url-1")
            expect(projectsService.currentUserProjects.get("all").toJS()[0].url).to.be.equal("url-1")
            expect(projectsService.currentUserProjects.get("recents").toJS()[0].url).to.be.equal("url-1")

        it "add sorted colorized_tags project object", () ->
            $rootScope.$digest()

            tags = [
                {name: "aa", color: "white"},
                {name: "xx", color: "red"},
                {name: "yy", color: "blue"}
            ];


            colorized_tags = projectsService.currentUserProjects.get("all").toJS()[0].colorized_tags

            expect(colorized_tags).to.be.eql(tags)

    it "newProject, create the wizard lightbox", () ->
        _injectService()

        projectsService.newProject()

        expect(mocks.lightboxFactory.create).to.have.been.calledWith("tg-lb-create-project", {
            "class": "wizard-create-project"
        })

    it "bulkUpdateProjectsOrder and then fetch projects again", () ->
        _injectService()

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

        mocks.resources.projects = {}
        mocks.resources.projects.bulkUpdateOrder = sinon.stub()
        mocks.resources.projects.bulkUpdateOrder.withArgs(projects_order).returns({
            then: thenStub
        })

        projectsService.fetchProjects = sinon.stub()

        projectsService.bulkUpdateProjectsOrder(projects_order)

        thenStub.callArg(0)

        expect(projectsService.fetchProjects).to.have.been.calledOnce

    it "getProjectBySlug", () ->
        _injectService()

        projectSlug = "project-slug"

        mocks.resources.projects = {}
        mocks.resources.projects.getProjectBySlug = sinon.stub()
        mocks.resources.projects.getProjectBySlug.withArgs(projectSlug).returns(true)

        expect(projectsService.getProjectBySlug(projectSlug)).to.be.true

    it "getProjectStats", () ->
        _injectService()

        projectId = 3

        mocks.resources.projects = {}
        mocks.resources.projects.getProjectStats = sinon.stub()
        mocks.resources.projects.getProjectStats.withArgs(projectId).returns(true)

        expect(projectsService.getProjectStats(projectId)).to.be.true
