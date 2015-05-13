describe "ProfileController", ->
    pageCtrl =  null
    provide = null
    controller = null
    mocks = {}

    projects = Immutable.fromJS([
        {id: 1},
        {id: 2},
        {id: 3}
    ])

    _mockAppTitle = () ->
        stub = sinon.stub()

        mocks.appTitle = {
            set: sinon.stub()
        }

        provide.value "$appTitle", mocks.appTitle

    _mockAuth = () ->
        stub = sinon.stub()

        mocks.auth = {
            getUser: sinon.stub()
        }

        provide.value "$tgAuth", mocks.auth

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

    it "define projects", () ->
        user = {
            username: "UserName"
        }

        mocks.auth.getUser.returns(user)

        ctrl = controller "Profile",
            $scope: {}

        expect(mocks.appTitle.set.withArgs(user.username)).to.be.calledOnce
