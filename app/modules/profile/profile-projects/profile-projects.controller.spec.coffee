describe "ProfileProjects", ->
    $controller = null
    $q = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockUserService = () ->
        mocks.userService = {
            attachUserContactsToProjects: sinon.stub()
        }

        provide.value "tgUserService", mocks.userService

    _mockProjectsService = () ->
        mocks.projectsService = {
            getProjectsByUserId: sinon.stub()
        }

        provide.value "tgProjectsService", mocks.projectsService

    _mockAuthService = () ->
        stub = sinon.stub()

        stub.returns({id: 2})

        provide.value "$tgAuth", {
            getUser: stub
        }

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockUserService()
            _mockAuthService()
            _mockProjectsService()

            return null

    _inject = (callback) ->
        inject (_$controller_, _$q_, _$rootScope_) ->
            $q = _$q_
            $rootScope = _$rootScope_
            $controller = _$controller_

    beforeEach ->
        module "taigaProfile"
        _mocks()
        _inject()

    it "load projects with contacts attached", (done) ->
        userId = 2
        projects = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        projectsWithContacts = [
            {id: 1, contacts: "fake"},
            {id: 2, contacts: "fake"},
            {id: 3, contacts: "fake"}
        ]

        mocks.projectsService.getProjectsByUserId = (userId) ->
            expect(userId).to.be.equal(userId)

            return $q (resolve, reject) ->
                resolve(projects)

        mocks.userService.attachUserContactsToProjects.withArgs(userId, projects).returns(projectsWithContacts)

        ctrl = $controller("ProfileProjects")

        ctrl.loadProjects().then () ->
            expect(ctrl.projects).to.be.equal(projectsWithContacts)
            done()

        $rootScope.$apply()
