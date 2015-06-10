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

    _mockTranslate = () ->
        mocks.translate = sinon.stub()

        provide.value "$translate", mocks.translate

    _mockAppMetaService = () ->
        mocks.appMetaService = {
            setAll: sinon.spy()
        }

        provide.value "tgAppMetaService", mocks.appMetaService

    _mockCurrentUser = () ->
        mocks.currentUser = {
            getUser: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUser

    _mockUserService = () ->
        mocks.userService = {
            getUserByUserName: sinon.stub()
        }

        provide.value "tgUserService", mocks.userService

    _mockRouteParams = () ->
        mocks.routeParams = {}

        provide.value "$routeParams", mocks.routeParams

    _mockXhrErrorService = () ->
        mocks.xhrErrorService = {
            response: sinon.spy()
        }

        provide.value "tgXhrErrorService", mocks.xhrErrorService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTranslate()
            _mockAppMetaService()
            _mockCurrentUser()
            _mockRouteParams()
            _mockUserService()
            _mockXhrErrorService()
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
            username: "username"
            full_name_display: "full-name-display"
            bio: "bio"
        })

        mocks.translate
            .withArgs('USER.PROFILE.PAGE_TITLE', {
                userFullName: user.get("full_name_display"),
                userUsername: user.get("username")
            })
            .promise().resolve('user-profile-page-title')

        mocks.userService.getUserByUserName.withArgs(mocks.routeParams.slug).promise().resolve(user)

        ctrl = $controller("Profile")

        setTimeout ( ->
            expect(ctrl.user).to.be.equal(user)
            expect(ctrl.isCurrentUser).to.be.false
            expect(mocks.appMetaService.setAll.calledWithExactly("user-profile-page-title", "bio")).to.be.true
            done()
        )

    it "non-existent user", (done) ->
        $scope = $rootScope.$new()

        mocks.routeParams.slug = "user-slug"

        xhr = {
            status: 404
        }

        mocks.userService.getUserByUserName.withArgs(mocks.routeParams.slug).promise().reject(xhr)

        ctrl = $controller("Profile")

        setTimeout ( ->
            expect(mocks.xhrErrorService.response.withArgs(xhr)).to.be.calledOnce
            done()
        )

    it "define current user", (done) ->
        $scope = $rootScope.$new()

        user = Immutable.fromJS({
            username: "username"
            full_name_display: "full-name-display"
            bio: "bio"
        })

        mocks.translate
            .withArgs('USER.PROFILE.PAGE_TITLE', {
                userFullName: user.get("full_name_display"),
                userUsername: user.get("username")
            })
            .promise().resolve('user-profile-page-title')

        mocks.currentUser.getUser.returns(user)

        ctrl = $controller("Profile")

        setTimeout ( ->
            expect(ctrl.user).to.be.equal(user)
            expect(ctrl.isCurrentUser).to.be.true
            expect(mocks.appMetaService.setAll.withArgs("user-profile-page-title", "bio")).to.be.calledOnce
            done()
        )
