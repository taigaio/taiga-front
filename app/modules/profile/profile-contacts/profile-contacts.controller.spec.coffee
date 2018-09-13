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
# File: profile/profile-contacts/profile-contacts.controller.spec.coffee
###

describe "ProfileContacts", ->
    $controller = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockUserService = () ->
        mocks.userServices = {
            getContacts: sinon.stub()
        }

        provide.value "tgUserService", mocks.userServices

    _mockCurrentUserService = () ->
        mocks.currentUserService = {
            getUser: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUserService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockUserService()
            _mockCurrentUserService()

            return null

    _inject = (callback) ->
        inject (_$controller_, _$rootScope_) ->
            $rootScope = _$rootScope_
            $controller = _$controller_

    beforeEach ->
        module "taigaProfile"
        _mocks()
        _inject()

    it "load current user contacts", (done) ->
        user = Immutable.fromJS({id: 2})

        contacts = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.currentUserService.getUser.returns(user)

        mocks.userServices.getContacts.withArgs(user.get("id")).promise().resolve(contacts)

        $scope = $rootScope.$new()

        ctrl = $controller("ProfileContacts", $scope, {
            user: user
        })

        ctrl.loadContacts().then () ->
            expect(ctrl.contacts).to.be.equal(contacts)
            expect(ctrl.isCurrentUser).to.be.true
            done()

    it "load user contacts", (done) ->
        user = Immutable.fromJS({id: 2})
        user2 = Immutable.fromJS({id: 3})

        contacts = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.currentUserService.getUser.returns(user2)

        mocks.userServices.getContacts.withArgs(user.get("id")).promise().resolve(contacts)

        $scope = $rootScope.$new()

        ctrl = $controller("ProfileContacts", $scope, {
            user: user
        })

        ctrl.loadContacts().then () ->
            expect(ctrl.contacts).to.be.equal(contacts)
            expect(ctrl.isCurrentUser).to.be.false
            done()
