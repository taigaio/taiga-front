describe "ProfileBar", ->
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

        $rootScope.$apply()

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

        $rootScope.$apply()

        expect(ctrl.project).to.be.equal(project)
