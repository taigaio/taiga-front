describe "tgProjectsService", ->
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
        inject (_$q_, _$rootScope_, _tgProjectsService_) ->
            $q = _$q_
            $rootScope = _$rootScope_
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

        mocks.resources.projects = {}
        mocks.resources.projects.bulkUpdateOrder = sinon.stub()
        mocks.resources.projects.bulkUpdateOrder.withArgs(projects_order).returns(true)

        result = projectsService.bulkUpdateProjectsOrder(projects_order)

        expect(result).to.be.true

    it "getProjectBySlug", () ->
        projectSlug = "project-slug"

        mocks.resources.projects = {}
        mocks.resources.projects.getProjectBySlug = sinon.stub()
        mocks.resources.projects.getProjectBySlug.withArgs(projectSlug).returns(true)

        expect(projectsService.getProjectBySlug(projectSlug)).to.be.true

    it "getProjectStats", () ->
        projectId = 3

        mocks.resources.projects = {}
        mocks.resources.projects.getProjectStats = sinon.stub()
        mocks.resources.projects.getProjectStats.withArgs(projectId).returns(true)

        expect(projectsService.getProjectStats(projectId)).to.be.true

    it "getProjectsByUserId", (done) ->
        projectId = 3

        projects = Immutable.fromJS([
            {id: 1, url: 'url-1'},
            {id: 2, url: 'url-2', tags: ['xx', 'yy', 'aa'], tags_colors: {xx: "red", yy: "blue", aa: "white"}}
        ])

        mocks.resources.projects = {}
        mocks.resources.projects.getProjectsByUserId = sinon.stub().promise()
        mocks.resources.projects.getProjectsByUserId.withArgs(projectId).resolve(projects)

        projectsService.getProjectsByUserId(projectId).then (projects) ->
            expect(projects.toJS()).to.be.eql([{
                    id: 1,
                    url: 'url-1'
                },
                {
                    id: 2,
                    url: 'url-2',
                    tags: ['xx', 'yy', 'aa'],
                    tags_colors: {xx: "red", yy: "blue", aa: "white"},
                    colorized_tags: [{name: 'aa', color: 'white'}, {name: 'xx', color: 'red'}, {name: 'yy', color: 'blue'}]
                }
            ])

            done()
