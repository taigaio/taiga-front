describe "ProfileContacts", ->
    $controller = null
    $q = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockUserService = () ->
        mocks.userService = {
            getUserContacts: sinon.stub()
        }

        provide.value "tgUserService", mocks.userService

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
        contacts = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.userService.getUserContacts = (userId) ->
            expect(userId).to.be.equal(userId)

            return $q (resolve, reject) ->
                resolve(contacts)

        ctrl = $controller("ProfileContacts")

        ctrl.loadContacts().then () ->
            expect(ctrl.contacts).to.be.equal(contacts)
            done()

        $rootScope.$apply()
