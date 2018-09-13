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
# File: projects/projects.service.spec.coffee
###

describe "tgProjectsService", ->
    projectsService = provide = $rootScope = null
    $q = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.projects = {}

        mocks.resources.projects.getProjectsByUserId = () ->
            return $q (resolve) ->
                resolve(Immutable.fromJS([]))

        provide.value "tgResources", mocks.resources

    _mockAuthService = () ->
        mocks.auth = {userData: Immutable.fromJS({id: 10})}

        provide.value "$tgAuth", mocks.auth

    _mockProjectUrl = () ->
        mocks.projectUrl = {get: sinon.stub()}

        mocks.projectUrl.get = (project) ->
            return "url-" + project.id

        provide.value "$projectUrl", mocks.projectUrl


    _inject = (callback) ->
        inject (_$q_, _$rootScope_, _tgProjectsService_) ->
            $q = _$q_
            $rootScope = _$rootScope_
            projectsService = _tgProjectsService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()
            _mockProjectUrl()
            _mockAuthService()

            return null

    beforeEach ->
        module "taigaProjects"
        _mocks()
        _inject()

    it "bulkUpdateProjectsOrder and then fetch projects again", () ->
        projects_order = [
            {"id": 8},
            {"id": 2},
            {"id": 3},
            {"id": 9},
            {"id": 1},
            {"id": 4},
            {"id": 10},
            {"id": 5},
            {"id": 6},
            {"id": 7},
            {"id": 11},
            {"id": 12},
        ]

        mocks.resources.projects = {}
        mocks.resources.projects.bulkUpdateOrder = sinon.stub()
        mocks.resources.projects.bulkUpdateOrder.withArgs(projects_order).returns(true)

        result = projectsService.bulkUpdateProjectsOrder(projects_order)

        expect(result).to.be.true

    it "getProjectStats", () ->
        projectId = 3

        mocks.resources.projects = {}
        mocks.resources.projects.getProjectStats = sinon.stub()
        mocks.resources.projects.getProjectStats.withArgs(projectId).returns(true)

        expect(projectsService.getProjectStats(projectId)).to.be.true

    it "getProjectBySlug", (done) ->
        projectSlug = "project-slug"
        project = Immutable.fromJS({id: 2, url: 'url-2', tags: ['xx', 'yy', 'aa'], tags_colors: {xx: "red", yy: "blue", aa: "white"}})

        mocks.resources.projects = {}
        mocks.resources.projects.getProjectBySlug = sinon.stub()
        mocks.resources.projects.getProjectBySlug.withArgs(projectSlug).promise().resolve(project)

        projectsService.getProjectBySlug(projectSlug).then (project) ->
            expect(project.toJS()).to.be.eql(
                {
                    id: 2,
                    url: 'url-2',
                    tags: ['xx', 'yy', 'aa'],
                    tags_colors: {xx: "red", yy: "blue", aa: "white"}
                }
            )

            done()

    it "getProjectsByUserId", (done) ->
        projectId = 3

        projects = Immutable.fromJS([
            {id: 1, url: 'url-1'},
            {id: 2, url: 'url-2', tags: ['xx', 'yy', 'aa'], tags_colors: {xx: "red", yy: "blue", aa: "white"}}
        ])

        mocks.resources.projects = {}
        mocks.resources.projects.getProjectsByUserId = sinon.stub()
        mocks.resources.projects.getProjectsByUserId.withArgs(projectId).promise().resolve(projects)

        projectsService.getProjectsByUserId(projectId).then (projects) ->
            expect(projects.toJS()).to.be.eql([{
                    id: 1,
                    url: 'url-1'
                },
                {
                    id: 2,
                    url: 'url-2',
                    tags: ['xx', 'yy', 'aa'],
                    tags_colors: {xx: "red", yy: "blue", aa: "white"}
                }
            ])

            done()

    it "validateTransferToken", (done) ->
        projectId = 3

        tokenValidation = Immutable.fromJS({})

        mocks.resources.projects = {}
        mocks.resources.projects.transferValidateToken = sinon.stub()
        mocks.resources.projects.transferValidateToken.withArgs(projectId).promise().resolve(tokenValidation)

        projectsService.transferValidateToken(projectId).then (projects) ->
            expect(projects.toJS()).to.be.eql({})
            done()
