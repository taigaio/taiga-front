describe "ProfileController", ->
    provide = null
    $controller = null
    $rootScope = null
    mocks = {}

    projects = Immutable.fromJS([
        {id: 1},
        {id: 2},
        {id: 3}
    ])

    _mockAppTitle = () ->
        stub = sinon.stub()

        mocks.appTitle = {
            set: sinon.spy()
        }

        provide.value "$appTitle", mocks.appTitle

    _mockCurrentUser = () ->
        stub = sinon.stub()

        mocks.currentUser = {
            getUser: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUser

    _mockUserService = () ->
        stub = sinon.stub()

        mocks.userService = {
            getUserByUserName: sinon.stub()
        }

        provide.value "tgUserService", mocks.userService

    _mockRouteParams = () ->
        stub = sinon.stub()

        mocks.routeParams = {}

        provide.value "$routeParams", mocks.routeParams

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockAppTitle()
            _mockCurrentUser()
            _mockRouteParams()
            _mockUserService()

            return null

    _inject = (callback) ->
        inject (_$controller_, _$rootScope_) ->
            $rootScope = _$rootScope_
            $controller = _$controller_

    beforeEach ->
        module "taigaProfile"

        _mocks()
        _inject()

    it "define external user", (done) ->
        $scope = $rootScope.$new()

        mocks.routeParams.slug = "user-slug"

        user = Immutable.fromJS({
            full_name: "full-name"
        })

        mocks.userService.getUserByUserName.withArgs(mocks.routeParams.slug).promise().resolve(user)

        ctrl = $controller("Profile")

        setTimeout ( ->
            expect(ctrl.user).to.be.equal(user)
            expect(ctrl.isCurrentUser).to.be.false
            expect(mocks.appTitle.set.calledWithExactly("full-name")).to.be.true

            done()
        )

    it "define current user", () ->
        $scope = $rootScope.$new()

        user = Immutable.fromJS({
            full_name_display: "full-name-display"
        })

        mocks.currentUser.getUser.returns(user)

        ctrl = $controller("Profile")

        expect(ctrl.user).to.be.equal(user)
        expect(ctrl.isCurrentUser).to.be.true
        expect(mocks.appTitle.set.calledWithExactly("full-name-display")).to.be.true
