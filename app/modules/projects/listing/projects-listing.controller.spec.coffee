describe "ProjectsListingController", ->
    pageCtrl =  null
    provide = null
    controller = null
    mocks = {}

    projects = Immutable.fromJS([
        {id: 1},
        {id: 2},
        {id: 3}
    ])

    _mockProjectsService = () ->
        stub = sinon.stub()

        mocks.projectsService = {
            currentUserProjects: {
                get: stub
            },
            newProject: sinon.stub()
        }

        stub.withArgs("all").returns(projects)

        provide.value "tgProjectsService", mocks.projectsService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockProjectsService()

            return null

    beforeEach ->
        module "taigaProjects"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "define projects", () ->
        pageCtrl = controller "ProjectsListing",
            $scope: {}

        expect(pageCtrl.projects).to.be.equal(projects)

    it "new project", () ->
        pageCtrl = controller "ProjectsListing",
            $scope: {}

        pageCtrl.newProject()

        expect(mocks.projectsService.newProject).to.be.calledOnce;
