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

    _mockAppMetaService = () ->
        mocks.appMetaService = {
            setAll: sinon.stub()
        }

        provide.value "tgAppMetaService", mocks.appMetaService

    _mockAuth = () ->
        mocks.auth = {
            userData: Immutable.fromJS({username: "UserName"})
        }

        provide.value "$tgAuth", mocks.auth

    _mockRouteParams = () ->
        provide.value "$routeParams", {
            pslug: "project-slug"
        }

    _mockXhrErrorService = () ->
        mocks.xhrErrorService = {
            response: sinon.spy()
        }

        provide.value "tgXhrErrorService", mocks.xhrErrorService

    _mockTranslate = () ->
        mocks.translate = {}
        mocks.translate.instant = sinon.stub()

        provide.value "$translate", mocks.translate

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockProjectsService()
            _mockRouteParams()
            _mockAppMetaService()
            _mockAuth()
            _mockXhrErrorService()
            _mockTranslate()
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
        project = Immutable.fromJS({
            name: "projectName"
        })

        mocks.projectService.getProjectBySlug.withArgs("project-slug").promise().resolve(project)

        ctrl = $controller "Project",
            $scope: {}

        expect(ctrl.user).to.be.equal(mocks.auth.userData)

    it "set page title", (done) ->
        $scope = $rootScope.$new()
        project = Immutable.fromJS({
            name: "projectName"
            description: "projectDescription"
        })

        mocks.translate.instant
            .withArgs('PROJECT.PAGE_TITLE', {
                projectName: project.get("name")
            })
            .returns('projectTitle')

        mocks.projectService.getProjectBySlug.withArgs("project-slug").promise().resolve(project)

        ctrl = $controller("Project")

        setTimeout ( ->
            expect(mocks.appMetaService.setAll.calledWithExactly("projectTitle", "projectDescription")).to.be.true
            done()
        )

    it "set local project variable", (done) ->
        project = Immutable.fromJS({
            name: "projectName"
        })

        mocks.projectService.getProjectBySlug.withArgs("project-slug").promise().resolve(project)

        ctrl = $controller("Project")

        setTimeout ( () ->
            expect(ctrl.project).to.be.equal(project)
            done()
        )

    it "handle project error", (done) ->
        xhr = {code: 403}

        mocks.projectService.getProjectBySlug.withArgs("project-slug").promise().reject(xhr)

        ctrl = $controller("Project")

        setTimeout (() ->
            expect(mocks.xhrErrorService.response.withArgs(xhr)).to.be.calledOnce
            done()
        )
