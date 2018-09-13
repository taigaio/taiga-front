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
# File: components/joy-ride/joy-ride.service.spec.coffee
###

describe "tgJoyRideService", ->
    joyRideService = provide = null
    mocks = {}

    _mockTranslate = () ->
        mocks.translate = {
            instant: sinon.stub()
        }

        provide.value "$translate", mocks.translate

    _mockCheckPermissionsService = () ->
        mocks.checkPermissionsService = {
            check: sinon.stub()
        }

        mocks.checkPermissionsService.check.returns(true)

        provide.value "tgCheckPermissionsService", mocks.checkPermissionsService

    _inject = (callback) ->
        inject (_tgJoyRideService_) ->
            joyRideService = _tgJoyRideService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTranslate()
            _mockCheckPermissionsService()
            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaComponents"
        _setup()
        _inject()

    it "get joyride by category", () ->
        example = {
            element: '.project-list > section:not(.ng-hide)',
            position: 'left',
            joyride: {
                title: 'test',
                text: 'test'
            },
            intro: '<h3>test</h3><p>test</p>'
        }

        mocks.translate.instant.returns('test')

        joyRide = joyRideService.get('dashboard')

        expect(joyRide).to.have.length(4)
        expect(joyRide[0]).to.be.eql(example)
