###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
