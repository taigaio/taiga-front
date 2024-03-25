###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
