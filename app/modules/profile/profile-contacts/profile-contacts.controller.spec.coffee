describe "ProfileContacts", ->
    $controller = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockUserService = () ->
        mocks.userServices = {
            getContacts: sinon.stub().promise()
        }

        provide.value "tgUserService", mocks.userServices

    _mocks = () ->
        module ($provide) ->
            provide = $provide
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

    it "load projects with contacts attached", (done) ->
        userId = 2
        contacts = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.userServices.getContacts.withArgs(userId).resolve(contacts)

        $scope = $rootScope.$new()

        ctrl = $controller("ProfileContacts", $scope, {
            userId: userId
        })

        ctrl.loadContacts().then () ->
            expect(ctrl.contacts).to.be.equal(contacts)
            done()
