###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "ProfileBar", ->
    $controller = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockUserService = () ->
        mocks.userService = {
            getStats:  sinon.stub()
        }

        provide.value "tgUserService", mocks.userService


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

    it "user stats filled", (done) ->
        userId = 2
        stats = Immutable.fromJS([
            {id: 1},
            {id: 2},
            {id: 3}
        ])

        mocks.userService.getStats.withArgs(userId).promise().resolve(stats)

        $scope = $rootScope.$new

        ctrl = $controller("ProfileBar", $scope, {
            user: Immutable.fromJS(id: userId)
        })

        setTimeout ( ->
            expect(ctrl.stats.toJS()).to.be.eql(stats.toJS())
            done()
        )
