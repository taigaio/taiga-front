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
# File: projects/listing/projects-listing.controller.spec.coffee
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
