describe "ProjectController", ->
    $controller = null
    $q = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockProjectsService = () ->
        mocks.projectService = {
            getProjectBySlug: sinon.stub()
        }

        provide.value "tgProjectsService", mocks.projectService

    _mockAppTitle = () ->
        mocks.appTitle = {
            set: sinon.stub()
        }

        provide.value "$appTitle", mocks.appTitle

    _mockAuth = () ->
        mocks.auth = {
            userData: Immutable.fromJS({username: "UserName"})
        }

        provide.value "$tgAuth", mocks.auth

    _mockRouteParams = () ->
        provide.value "$routeParams", {
            pslug: "project-slug"
        }

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockProjectsService()
            _mockRouteParams()
            _mockAppTitle()
            _mockAuth()

            return null

    _inject = (callback) ->
        inject (_$controller_, _$q_, _$rootScope_) ->
            $q = _$q_
            $rootScope = _$rootScope_
            $controller = _$controller_

    beforeEach ->
        module "taigaProjects"
        _mocks()
        _inject()

    it "set local user", () ->
        thenStub = sinon.stub()

        mocks.projectService.getProjectBySlug.withArgs("project-slug").returns({
            then: thenStub
        })

        ctrl = $controller "Project",
            $scope: {}

        expect(ctrl.user).to.be.equal(mocks.auth.userData)

    it "set page title", () ->
        project = Immutable.fromJS({
            name: "projectName"
        })

        thenStub = sinon.stub()

        mocks.projectService.getProjectBySlug.withArgs("project-slug").returns({
            then: thenStub
        })

        ctrl = $controller("Project")

        thenStub.callArg(0, project)

        expect(mocks.appTitle.set.withArgs("projectName")).to.be.calledOnce


    it "set local project variable", () ->
        project = Immutable.fromJS({
            name: "projectName"
        })

        thenStub = sinon.stub()

        mocks.projectService.getProjectBySlug.withArgs("project-slug").returns({
            then: thenStub
        })

        ctrl = $controller("Project")

        thenStub.callArg(0, project)

        expect(ctrl.project).to.be.equal(project)
