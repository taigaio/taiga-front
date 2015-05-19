describe "tgCurrentUserService", ->
    currentUserService = provide = null
    mocks = {}

    _mockTgStorage = () ->
        mocks.storageService = {
            get: sinon.stub()
        }

        provide.value "$tgStorage", mocks.storageService

    _mockProjectsService = () ->
        mocks.projectsService = {
            getProjectsByUserId: sinon.stub().promise(),
            bulkUpdateProjectsOrder: sinon.stub().promise()
        }

        provide.value "tgProjectsService", mocks.projectsService

    _inject = (callback) ->
        inject (_tgCurrentUserService_) ->
            currentUserService = _tgCurrentUserService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgStorage()
            _mockProjectsService()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaCommon"
        _setup()
        _inject()

    describe "get user", () ->
        it "return the user if it is defined", () ->
            currentUserService._user = 123

            expect(currentUserService.getUser()).to.be.equal(123)

        it "get user form storage if it is not defined", () ->
            user = {id: 1, name: "fake1"}

            currentUserService.setUser = sinon.spy()
            mocks.storageService.get.withArgs("userInfo").returns(user)

            _user = currentUserService.getUser()

            expect(currentUserService.setUser).to.be.calledOnce

    it "set user and load user info", (done) ->
        user = Immutable.fromJS({id: 1, name: "fake1"})

        projects = Immutable.fromJS([
            {id: 1, name: "fake1"},
            {id: 2, name: "fake2"},
            {id: 3, name: "fake3"},
            {id: 4, name: "fake4"},
            {id: 5, name: "fake5"}
        ])

        mocks.projectsService.getProjectsByUserId = sinon.stub().promise()
        mocks.projectsService.getProjectsByUserId.withArgs(user.get("id")).resolve(projects)

        currentUserService.setUser(user).then () ->
            expect(currentUserService._user).to.be.equal(user)
            expect(currentUserService.projects.get("all").size).to.be.equal(5)
            expect(currentUserService.projects.get("recents").size).to.be.equal(5)
            expect(currentUserService.projectsById.size).to.be.equal(5)
            expect(currentUserService.projectsById.get("3").get("name")).to.be.equal("fake3")

            done()

    it "bulkUpdateProjectsOrder and reload projects", (done) ->
        fakeData = [{id: 1, id: 2}]

        currentUserService._loadProjects = sinon.spy()

        mocks.projectsService.bulkUpdateProjectsOrder.withArgs(fakeData).resolve()

        currentUserService.bulkUpdateProjectsOrder(fakeData).then () ->
            expect(currentUserService._loadProjects).to.be.callOnce

            done()

    it "is authenticated", () ->
        currentUserService.getUser = sinon.stub()
        currentUserService.getUser.returns({})

        expect(currentUserService.isAuthenticated()).to.be.true

        currentUserService.getUser.returns(null)

        expect(currentUserService.isAuthenticated()).to.be.false

    it "remove user", () ->
        currentUserService._user = true

        currentUserService.removeUser()

        expect(currentUserService._user).to.be.null
