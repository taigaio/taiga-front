describe "PageController", ->
    pageCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockPageParams = () ->
        mocks.pageParams = {}

        provide.value "pageParams", mocks.pageParams

    _mockAuth = () ->
        mocks.auth = {
            isAuthenticated: sinon.stub()
        }

        provide.value "$tgAuth", mocks.auth

    _mockAppTitle = () ->
        mocks.appTitle = {
            set: sinon.spy()
        }

        provide.value "$appTitle", mocks.appTitle

    _mockLocation = () ->
        mocks.location = {
            path: sinon.spy()
        }

        provide.value "$tgLocation", mocks.location

    _mockNavUrls = () ->
        mocks.navUrls = {
            resolve: sinon.stub()
        }

        provide.value "$tgNavUrls", mocks.navUrls

    _mockTranslate = () ->
        mocks.translate = sinon.stub()

        provide.value "$translate", mocks.translate

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockAppTitle()
            _mockPageParams()
            _mockAuth()
            _mockLocation()
            _mockNavUrls()
            _mockTranslate()

            return null

    beforeEach ->
        module "taigaPage"

        _mocks()

        inject ($controller) ->
            controller = $controller

    describe "auth", () ->
        it "if auth is required and the user is not logged redirect to login page", () ->
            locationPath = "location-path"

            mocks.pageParams.authRequired = true
            mocks.auth.isAuthenticated.returns(false)
            mocks.navUrls.resolve.withArgs("login").returns(locationPath)

            pageCtrl = controller "Page",
                $scope: {}

            expect(mocks.location.path.withArgs(locationPath)).have.been.calledOnce

        it "if auth is not required no redirect to login page", () ->
            locationPath = "location-path"

            mocks.pageParams.authRequired = false
            mocks.auth.isAuthenticated.returns(false)
            mocks.navUrls.resolve.withArgs("login").returns(locationPath)

            pageCtrl = controller "Page",
                $scope: {}

            expect(mocks.location.path).have.callCount(0)

        it "if auth is required and the user is logged no redirect", () ->
            locationPath = "location-path"

            mocks.pageParams.authRequired = true
            mocks.auth.isAuthenticated.returns(true)
            mocks.navUrls.resolve.withArgs("login").returns(locationPath)

            pageCtrl = controller "Page",
                $scope: {}

            expect(mocks.location.path).have.callCount(0)

    describe "page title", () ->
        it "if title is defined set it", () ->
            thenStub = sinon.stub()

            mocks.pageParams.title = "TITLE"
            mocks.translate.withArgs("TITLE").returns({
                then: thenStub
            })

            pageCtrl = controller "Page",
                $scope: {}

            thenStub.callArg(0, "TITLE")

            expect(mocks.appTitle.set.withArgs("TITLE")).have.been.calledOnce

        it "if title is not defined not call appTitle", () ->
            pageCtrl = controller "Page",
                $scope: {}

            expect(mocks.translate).have.callCount(0)
            expect(mocks.appTitle.set.withArgs("TITLE")).have.callCount(0)
