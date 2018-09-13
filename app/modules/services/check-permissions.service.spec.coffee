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
# File: services/check-permissions.service.spec.coffee
###

describe "tgCheckPermissionsService", ->
    checkPermissionsService = provide = null
    mocks = {}

    _mockProjectService = () ->
        mocks.projectService = {
            project: sinon.stub()
        }

        provide.value "tgProjectService", mocks.projectService

    _inject = () ->
        inject (_tgCheckPermissionsService_) ->
            checkPermissionsService = _tgCheckPermissionsService_

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockProjectService()

            return null

    beforeEach ->
        module "taigaCommon"
        _mocks()
        _inject()

    it "the user has perms", () ->
        mocks.projectService.project = Immutable.fromJS({
            my_permissions: ['add_us']
        })

        perm = checkPermissionsService.check('add_us')

        expect(perm).to.be.true

    it "the user hasn't perms", () ->
        mocks.projectService.project = Immutable.fromJS({
            my_permissions: []
        })

        perm = checkPermissionsService.check('add_us')

        expect(perm).to.be.false
