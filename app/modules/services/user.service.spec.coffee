# pending new resouercees

describe.skip "UserService", ->
    userService = null
    $q = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}
        mocks.resources.projects = {
            listByMember: sinon.stub()
        }

        mocks.resources.users = {
            contacts: sinon.stub()
        }

        provide.value "$tgResources", mocks.resources

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()

            return null

    _inject = (callback) ->
        inject (_tgUserService_, _$q_, _$rootScope_) ->
            userService = _tgUserService_
            $q = _$q_
            $rootScope = _$rootScope_

    beforeEach ->
        module "taigaCommon"
        _mocks()
        _inject()

    it "get user projects", (done) ->
        userId = 2

        projects = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.resources.projects.listByMember = (userId) ->
            expect(userId).to.be.equal(userId)

            return $q (resolve, reject) ->
                resolve(projects)

        userService.getProjects(userId).then (_projects_) ->
            expect(_projects_.toJS()).to.be.eql(projects)
            done()

        $rootScope.$apply()

    it "attach user contacts to projects", (done) ->
        userId = 2

        class Project
            constructor: (@id, @members) ->

        projects = Immutable.fromJS([
            new Project(1, [1, 2, 3]),
            new Project(1, [2, 3]),
            new Project(1, [1])
        ])

        contacts = Immutable.fromJS([
            {id: 1, name: "fake1"},
            {id: 2, name: "fake2"},
            {id: 3, name: "fake3"}
        ])

        mocks.resources.users.contacts = (userId) ->
            expect(userId).to.be.equal(userId)

            return $q (resolve, reject) ->
                resolve(contacts)

        userService.attachUserContactsToProjects(userId, projects).then (_projects_) ->
            contacts = _projects_.get(0).contacts

            console.log _projects_.get(0)

            expect(contacts[0]).to.be.equal('fake1')
            done()

        $rootScope.$apply()

    it "get user contacts", (done) ->
        userId = 2

        contacts = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.resources.user.contacts = (userId) ->
            expect(userId).to.be.equal(userId)

            return $q (resolve, reject) ->
                resolve(contacts)

        userService.getUserContacts(userId).then (_contacts_) ->
            expect(_contacts_.toJS()).to.be.eql(contacts)
            done()

        $rootScope.$apply()
