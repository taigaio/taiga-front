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
# File: profile/profile-projects/profile-projects.controller.spec.coffee
###

describe "ProfileProjects", ->
    $controller = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockUserService = () ->
        mocks.userService = {
            attachUserContactsToProjects: sinon.stub()
        }

        provide.value "tgUserService", mocks.userService

    _mockProjectsService = () ->
        mocks.projectsService = {
            getProjectsByUserId: sinon.stub()
        }

        provide.value "tgProjectsService", mocks.projectsService

    _mockAuthService = () ->
        stub = sinon.stub()

        stub.returns({id: 2})

        provide.value "$tgAuth", {
            getUser: stub
        }

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockUserService()
            _mockAuthService()
            _mockProjectsService()

            return null

    _inject = (callback) ->
        inject (_$controller_,  _$rootScope_) ->
            $rootScope = _$rootScope_
            $controller = _$controller_

    beforeEach ->
        module "taigaProfile"
        _mocks()
        _inject()

    it "load projects with contacts attached", (done) ->
        user = Immutable.fromJS({id: 2})
        projects = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        projectsWithContacts = [
            {id: 1, contacts: "fake"},
            {id: 2, contacts: "fake"},
            {id: 3, contacts: "fake"}
        ]

        mocks.projectsService.getProjectsByUserId.withArgs(user.get("id")).promise().resolve(projects)
        mocks.userService.attachUserContactsToProjects.withArgs(user.get("id"), projects).returns(projectsWithContacts)

        $scope = $rootScope.$new()

        ctrl = $controller("ProfileProjects", $scope, {
            user: user
        })

        ctrl.loadProjects().then () ->
            expect(ctrl.projects).to.be.equal(projectsWithContacts)
            done()
