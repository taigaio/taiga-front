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
# File: profile/profile-hints/profile-hints.controller.spec.coffee
###

describe "ProfileHints", ->
    $controller = null
    $provide = null

    mocks = {}

    _mockTranslate = () ->
        mocks.translateService = {}
        mocks.translateService.instant = sinon.stub()

        $provide.value "$translate", mocks.translateService

    _mocks = () ->
        module (_$provide_) ->
            $provide = _$provide_
            _mockTranslate()

            return null

    beforeEach ->
        module "taigaProfile"
        _mocks()

        inject (_$controller_) ->
            $controller = _$controller_

    it "random hint generator", (done) ->
        mocks.translateService.instant.returns("fill")

        ctrl = $controller("ProfileHints")

        setTimeout ( ->
                expect(ctrl.hint.title).to.be.equal("fill")
                expect(ctrl.hint.text).to.be.equal("fill")
                expect(ctrl.hint.linkText).to.have.length.above(1)
                done()
        )
