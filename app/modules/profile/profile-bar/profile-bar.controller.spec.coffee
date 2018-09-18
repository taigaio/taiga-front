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
# File: profile/profile-bar/profile-bar.controller.spec.coffee
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
