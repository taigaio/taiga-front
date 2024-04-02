###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "ProjectsListingController", ->
    pageCtrl =  null
    provide = null
    controller = null
    mocks = {}

    projects = Immutable.fromJS({
        all: [
            {id: 1},
            {id: 2},
            {id: 3}
        ]
    })

    _mockCurrentUserService = () ->
        stub = sinon.stub()

        mocks.currentUserService = {
            projects: projects
        }

        provide.value "tgCurrentUserService", mocks.currentUserService

    _mockProjectsService = () ->
        stub = sinon.stub()

        provide.value "tgProjectsService", mocks.projectsService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockCurrentUserService()

            return null

    beforeEach ->
        module "taigaProjects"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "define projects", () ->
        pageCtrl = controller "ProjectsListing",
            $scope: {}

        expect(pageCtrl.projects).to.be.equal(projects.get('all'))
