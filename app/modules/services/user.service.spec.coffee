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
# File: services/user.service.spec.coffee
###

describe "UserService", ->
    userService = null
    $q = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}
        mocks.resources.users = {
            getProjects: sinon.stub(),
            getContacts: sinon.stub()
        }

        provide.value "tgResources", mocks.resources

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

    it "attach user contacts to projects", (done) ->
        userId = 2

        projects = Immutable.fromJS([
            {id: 1, members: [1, 2, 3]},
            {id: 2, members: [2, 3]},
            {id: 3, members: [1]}
        ])

        contacts = Immutable.fromJS([
            {id: 1, name: "fake1"},
            {id: 2, name: "fake2"},
            {id: 3, name: "fake3"}
        ])

        mocks.resources.users.getContacts = sinon.stub()
        mocks.resources.users.getContacts.withArgs(userId).promise().resolve(contacts)

        userService.attachUserContactsToProjects(userId, projects).then (_projects_) ->
            contacts = _projects_.get(0).get("contacts")

            expect(contacts.get(0).get("name")).to.be.equal('fake1')

            done()

    it "get user contacts", (done) ->
        userId = 2

        contacts = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.resources.users.getContacts = sinon.stub()
        mocks.resources.users.getContacts.withArgs(userId).promise().resolve(contacts)

        userService.getContacts(userId).then (_contacts_) ->
            expect(_contacts_).to.be.eql(contacts)
            done()

        $rootScope.$apply()

    it "get user liked", (done) ->
        userId = 2
        pageNumber = 1
        objectType = null
        textQuery = null

        liked = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.resources.users.getLiked = sinon.stub()
        mocks.resources.users.getLiked.withArgs(userId, pageNumber, objectType, textQuery)
                                      .promise()
                                      .resolve(liked)

        userService.getLiked(userId, pageNumber, objectType, textQuery).then (_liked_) ->
            expect(_liked_).to.be.eql(liked)
            done()

        $rootScope.$apply()

    it "get user voted", (done) ->
        userId = 2
        pageNumber = 1
        objectType = null
        textQuery = null

        voted = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.resources.users.getVoted = sinon.stub()
        mocks.resources.users.getVoted.withArgs(userId, pageNumber, objectType, textQuery)
                                      .promise()
                                      .resolve(voted)

        userService.getVoted(userId, pageNumber, objectType, textQuery).then (_voted_) ->
            expect(_voted_).to.be.eql(voted)
            done()

        $rootScope.$apply()

    it "get user watched", (done) ->
        userId = 2
        pageNumber = 1
        objectType = null
        textQuery = null

        watched = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.resources.users.getWatched = sinon.stub()
        mocks.resources.users.getWatched.withArgs(userId, pageNumber, objectType, textQuery)
                                        .promise()
                                        .resolve(watched)

        userService.getWatched(userId, pageNumber, objectType, textQuery).then (_watched_) ->
            expect(_watched_).to.be.eql(watched)
            done()

        $rootScope.$apply()

    it "get user by username", (done) ->
        username = "username-1"

        user = {id: 1}

        mocks.resources.users.getUserByUsername = sinon.stub()
        mocks.resources.users.getUserByUsername.withArgs(username).promise().resolve(user)

        userService.getUserByUserName(username).then (_user_) ->
            expect(_user_).to.be.eql(user)
            done()
