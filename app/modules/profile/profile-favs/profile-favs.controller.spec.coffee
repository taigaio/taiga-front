###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: profile/profile-favs/profile-favs.controller.spec.coffee
###

describe "ProfileLiked", ->
    $controller = null
    provide = null
    $rootScope = null
    mocks = {}

    user = Immutable.fromJS({id: 2})

    _mockUserService = () ->
        mocks.userServices = {
            getLiked: sinon.stub()
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

    it "load paginated items", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileLiked", $scope, {user: user})

        items1 = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })
        items2 = Immutable.fromJS({
            data: [
                {id: 4},
                {id: 5},
            ],
            next: false
        })

        mocks.userServices.getLiked.withArgs(user.get("id"), 1, null, null).promise().resolve(items1)
        mocks.userServices.getLiked.withArgs(user.get("id"), 2, null, null).promise().resolve(items2)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.loadItems().then () =>
            expectItems = items1.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.null
            expect(ctrl.q).to.be.null

            ctrl.loadItems().then () =>
                expectItems = expectItems.concat(items2.get("data"))

                expect(ctrl.items.equals(expectItems)).to.be.true
                expect(ctrl.scrollDisabled).to.be.true
                expect(ctrl.type).to.be.null
                expect(ctrl.q).to.be.null
                done()

    it "filter items by text query", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileLiked", $scope, {user: user})

        textQuery = "_test_"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getLiked.withArgs(user.get("id"), 1, null, textQuery).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.q = textQuery

        ctrl.loadItems().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.null
            expect(ctrl.q).to.be.equal(textQuery)
            done()

    it "show loading spinner during the call to the api", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileLiked", $scope, {user: user})

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mockPromise = mocks.userServices.getLiked.withArgs(user.get("id"), 1, null, null).promise()

        expect(ctrl.isLoading).to.be.undefined

        promise = ctrl.loadItems()

        expect(ctrl.isLoading).to.be.true

        mockPromise.resolve(items)

        promise.then () =>
            expect(ctrl.isLoading).to.be.false
            done()

    it "show no results placeholder", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileLiked", $scope, {user: user})

        items = Immutable.fromJS({
            data: [],
            next: false
        })

        mocks.userServices.getLiked.withArgs(user.get("id"), 1, null, null).promise().resolve(items)

        expect(ctrl.hasNoResults).to.be.undefined

        ctrl.loadItems().then () =>
            expect(ctrl.hasNoResults).to.be.true
            done()


describe "ProfileVoted", ->
    $controller = null
    provide = null
    $rootScope = null
    mocks = {}

    user = Immutable.fromJS({id: 2})

    _mockUserService = () ->
        mocks.userServices = {
            getVoted: sinon.stub()
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

    it "load paginated items", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileVoted", $scope, {user: user})

        items1 = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })
        items2 = Immutable.fromJS({
            data: [
                {id: 4},
                {id: 5},
            ],
            next: false
        })

        mocks.userServices.getVoted.withArgs(user.get("id"), 1, null, null).promise().resolve(items1)
        mocks.userServices.getVoted.withArgs(user.get("id"), 2, null, null).promise().resolve(items2)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.loadItems().then () =>
            expectItems = items1.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.null
            expect(ctrl.q).to.be.null

            ctrl.loadItems().then () =>
                expectItems = expectItems.concat(items2.get("data"))

                expect(ctrl.items.equals(expectItems)).to.be.true
                expect(ctrl.scrollDisabled).to.be.true
                expect(ctrl.type).to.be.null
                expect(ctrl.q).to.be.null
                done()

    it "filter items by text query", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileVoted", $scope, {user: user})

        textQuery = "_test_"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getVoted.withArgs(user.get("id"), 1, null, textQuery).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.q = textQuery

        ctrl.loadItems().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.null
            expect(ctrl.q).to.be.equal(textQuery)
            done()

    it "show only items of epics", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileVoted", $scope, {user: user})

        type = "epic"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getVoted.withArgs(user.get("id"), 1, type, null).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.showEpicsOnly().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.type
            expect(ctrl.q).to.be.null
            done()

    it "show only items of user stories", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileVoted", $scope, {user: user})

        type = "userstory"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getVoted.withArgs(user.get("id"), 1, type, null).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.showUserStoriesOnly().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.type
            expect(ctrl.q).to.be.null
            done()

    it "show only items of tasks", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileVoted", $scope, {user: user})

        type = "task"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getVoted.withArgs(user.get("id"), 1, type, null).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.showTasksOnly().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.type
            expect(ctrl.q).to.be.null
            done()

    it "show only items of issues", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileVoted", $scope, {user: user})

        type = "issue"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getVoted.withArgs(user.get("id"), 1, type, null).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.showIssuesOnly().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.type
            expect(ctrl.q).to.be.null
            done()

    it "show loading spinner during the call to the api", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileVoted", $scope, {user: user})

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mockPromise = mocks.userServices.getVoted.withArgs(user.get("id"), 1, null, null).promise()

        expect(ctrl.isLoading).to.be.undefined

        promise = ctrl.loadItems()

        expect(ctrl.isLoading).to.be.true

        mockPromise.resolve(items)

        promise.then () =>
            expect(ctrl.isLoading).to.be.false
            done()

    it "show no results placeholder", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileVoted", $scope, {user: user})

        items = Immutable.fromJS({
            data: [],
            next: false
        })

        mocks.userServices.getVoted.withArgs(user.get("id"), 1, null, null).promise().resolve(items)

        expect(ctrl.hasNoResults).to.be.undefined

        ctrl.loadItems().then () =>
            expect(ctrl.hasNoResults).to.be.true
            done()

describe "ProfileWatched", ->
    $controller = null
    provide = null
    $rootScope = null
    mocks = {}

    user = Immutable.fromJS({id: 2})

    _mockUserService = () ->
        mocks.userServices = {
            getWatched: sinon.stub()
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

    it "load paginated items", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileWatched", $scope, {user: user})

        items1 = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })
        items2 = Immutable.fromJS({
            data: [
                {id: 4},
                {id: 5},
            ],
            next: false
        })

        mocks.userServices.getWatched.withArgs(user.get("id"), 1, null, null).promise().resolve(items1)
        mocks.userServices.getWatched.withArgs(user.get("id"), 2, null, null).promise().resolve(items2)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.loadItems().then () =>
            expectItems = items1.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.null
            expect(ctrl.q).to.be.null

            ctrl.loadItems().then () =>
                expectItems = expectItems.concat(items2.get("data"))

                expect(ctrl.items.equals(expectItems)).to.be.true
                expect(ctrl.scrollDisabled).to.be.true
                expect(ctrl.type).to.be.null
                expect(ctrl.q).to.be.null
                done()

    it "filter items by text query", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileWatched", $scope, {user: user})

        textQuery = "_test_"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getWatched.withArgs(user.get("id"), 1, null, textQuery).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.q = textQuery

        ctrl.loadItems().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.null
            expect(ctrl.q).to.be.equal(textQuery)
            done()

    it "show only items of projects", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileWatched", $scope, {user: user})

        type = "project"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getWatched.withArgs(user.get("id"), 1, type, null).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.showProjectsOnly().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.type
            expect(ctrl.q).to.be.null
            done()

    it "show only items of epics", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileWatched", $scope, {user: user})

        type = "epic"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getWatched.withArgs(user.get("id"), 1, type, null).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.showEpicsOnly().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.type
            expect(ctrl.q).to.be.null
            done()

    it "show only items of user stories", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileWatched", $scope, {user: user})

        type = "userstory"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getWatched.withArgs(user.get("id"), 1, type, null).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.showUserStoriesOnly().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.type
            expect(ctrl.q).to.be.null
            done()

    it "show only items of tasks", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileWatched", $scope, {user: user})

        type = "task"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getWatched.withArgs(user.get("id"), 1, type, null).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.showTasksOnly().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.type
            expect(ctrl.q).to.be.null
            done()

    it "show only items of issues", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileWatched", $scope, {user: user})

        type = "issue"

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mocks.userServices.getWatched.withArgs(user.get("id"), 1, type, null).promise().resolve(items)

        expect(ctrl.items.size).to.be.equal(0)
        expect(ctrl.scrollDisabled).to.be.false
        expect(ctrl.type).to.be.null
        expect(ctrl.q).to.be.null

        ctrl.showIssuesOnly().then () =>
            expectItems = items.get("data")

            expect(ctrl.items.equals(expectItems)).to.be.true
            expect(ctrl.scrollDisabled).to.be.false
            expect(ctrl.type).to.be.type
            expect(ctrl.q).to.be.null
            done()

    it "show loading spinner during the call to the api", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileWatched", $scope, {user: user})

        items = Immutable.fromJS({
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ],
            next: true
        })

        mockPromise = mocks.userServices.getWatched.withArgs(user.get("id"), 1, null, null).promise()

        expect(ctrl.isLoading).to.be.undefined

        promise = ctrl.loadItems()

        expect(ctrl.isLoading).to.be.true

        mockPromise.resolve(items)

        promise.then () =>
            expect(ctrl.isLoading).to.be.false
            done()

    it "show no results placeholder", (done) ->
        $scope = $rootScope.$new()
        ctrl = $controller("ProfileWatched", $scope, {user: user})

        items = Immutable.fromJS({
            data: [],
            next: false
        })

        mocks.userServices.getWatched.withArgs(user.get("id"), 1, null, null).promise().resolve(items)

        expect(ctrl.hasNoResults).to.be.undefined

        ctrl.loadItems().then () =>
            expect(ctrl.hasNoResults).to.be.true
            done()
