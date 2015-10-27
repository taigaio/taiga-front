describe "tgProjectService", ->
    $provide = null
    mocks = {}
    projectService = null

    _mockProjectsService = () ->
        mocks.projectsService = {
            getProjectBySlug: sinon.stub()
        }

        $provide.value "tgProjectsService", mocks.projectsService

    _mockXhrErrorService = () ->
        mocks.xhrErrorService = {
            response: sinon.stub()
        }

        $provide.value "tgXhrErrorService", mocks.xhrErrorService

    _mocks = () ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockProjectsService()
            _mockXhrErrorService()

            return null

    _setup = () ->
        _mocks()

    _inject = () ->
        inject (_tgProjectService_) ->
            projectService = _tgProjectService_

    beforeEach ->
        module "taigaCommon"

        _setup()
        _inject()

    it "update section and add it at the begginning of section breadcrumb", () ->
        section = "fakeSection"
        breadcrumb = ["fakeSection"]

        projectService.setSection(section)

        expect(projectService.section).to.be.equal(section)
        expect(projectService.sectionsBreadcrumb.toJS()).to.be.eql(breadcrumb)

        section = "fakeSection222"
        breadcrumb = ["fakeSection", "fakeSection222"]
        projectService.setSection(section)

        expect(projectService.sectionsBreadcrumb.toJS()).to.be.eql(breadcrumb)

    it "set project if the project slug has changed", (done) ->
        projectService.setProject = sinon.spy()

        project = Immutable.Map({
            id: 1,
            slug: 'slug-1',
            members: []
        })

        mocks.projectsService.getProjectBySlug.withArgs('slug-1').promise().resolve(project)
        mocks.projectsService.getProjectBySlug.withArgs('slug-2').promise().resolve(project)

        projectService.setProjectBySlug('slug-1')
            .then () -> projectService.setProjectBySlug('slug-1')
            .then () -> projectService.setProjectBySlug('slug-2')
            .finally () ->
                expect(projectService.setProject).to.be.called.twice;
                done()

    it "set project and set active members", () ->
        project = Immutable.fromJS({
            name: 'test project',
            members: [
                {is_active: true},
                {is_active: false},
                {is_active: true},
                {is_active: false},
                {is_active: false}
            ]
        })

        projectService.setProject(project)

        expect(projectService.project).to.be.equal(project)
        expect(projectService.activeMembers.size).to.be.equal(2)

    it "fetch project", (done) ->
        project = Immutable.Map({
            id: 1,
            slug: 'slug',
            members: []
        })

        projectService._project = project

        mocks.projectsService.getProjectBySlug.withArgs(project.get('slug')).promise().resolve(project)

        projectService.fetchProject().then () ->
            expect(projectService.project).to.be.equal(project)
            done()

    it "clean project", () ->
        projectService._section = "fakeSection"
        projectService._sectionsBreadcrumb = ["fakeSection"]
        projectService._activeMembers = ["fakeMember"]
        projectService._project = Immutable.Map({
            id: 1,
            slug: 'slug',
            members: []
        })

        projectService.cleanProject()

        expect(projectService.project).to.be.null;
        expect(projectService.activeMembers.size).to.be.equal(0);
        expect(projectService.section).to.be.null;
        expect(projectService.sectionsBreadcrumb.size).to.be.equal(0);
