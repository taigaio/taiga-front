describe "PageController", ->
    pageCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockAuth = () ->
        mocks.authService = {
            getUser: sinon.stub()
        }

        provide.value "$tgAuth", mocks.authService

    _mockAppTitle = () ->
        mocks.appTitle = {
            set: sinon.spy()
        }

        provide.value "$appTitle", mocks.appTitle

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockAppTitle()
            _mockAuth()

            return null

    beforeEach ->
        module "taigaProfile"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "set the username as title", () ->
        user = {
            username: 'UserName'
        }

        mocks.authService.getUser.returns(user)

        pageCtrl = controller "ProfilePage",
            $scope: {}

        expect(mocks.appTitle.set.withArgs(user.username)).have.been.calledOnce
