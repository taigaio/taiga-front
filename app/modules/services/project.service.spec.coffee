describe "tgProjectService", ->
    $provide = null
    mocks = {}
    projectService = null

    _mockProjectsService = () ->
        mocks.projectsService = {
            getProjectBySlug: sinon.stub()
        }

        $provide.value "tgProjectsService", mocks.projectsService

    _mocks = () ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockProjectsService()

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
        breadcrumb = ["fakeSection222","fakeSection"]
        projectService.setSection(section)

        expect(projectService.sectionsBreadcrumb.toJS()).to.be.eql(breadcrumb)

    it "set project if the project slug has changed", () ->
        projectService.fetchProject = sinon.spy()

        pslug = "slug-1"

        projectService.setProject(pslug)

        expect(projectService.fetchProject).to.be.calledOnce

        projectService.setProject(pslug)

        expect(projectService.fetchProject).to.be.calledOnce

        projectService.setProject("slug-2")

        expect(projectService.fetchProject).to.be.calledTwice

    it "fetch project", (done) ->
        project = Immutable.Map({id: 1})
        pslug = "slug-1"

        projectService._pslug = pslug

        mocks.projectsService.getProjectBySlug.withArgs(pslug).promise().resolve(project)

        projectService.fetchProject().then () ->
            expect(projectService.project).to.be.equal(project)
            done()
