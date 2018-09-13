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
# File: projects/components/like-project-button/like-project-button.service.spec.coffee
###

describe "tgLikeProjectButtonService", ->
    likeButtonService = null
    provide = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            projects: {
                likeProject: sinon.stub(),
                unlikeProject: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResources

    _mockTgCurrentUserService = () ->
        mocks.tgCurrentUserService = {
            setProjects: sinon.stub(),
            projects: Immutable.fromJS({
                all: [
                    {
                        id: 4,
                        total_fans: 2,
                        is_fan: false
                    },
                    {
                        id: 5,
                        total_fans: 7,
                        is_fan: true
                    },
                    {
                        id: 6,
                        total_fans: 4,
                        is_fan: true
                    }
                ]
            })
        }

        provide.value "tgCurrentUserService", mocks.tgCurrentUserService

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            setProject: sinon.stub()
        }

        provide.value "tgProjectService", mocks.tgProjectService

    _inject = (callback) ->
        inject (_tgLikeProjectButtonService_) ->
            likeButtonService = _tgLikeProjectButtonService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgResources()
            _mockTgCurrentUserService()
            _mockTgProjectService()
            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaProjects"
        _setup()
        _inject()

    it "like", (done) ->
        projectId = 4

        mocks.tgResources.projects.likeProject.withArgs(projectId).promise().resolve()

        newProject = {
            id: 4,
            total_fans: 3,
            is_fan: true
        }

        mocks.tgProjectService.project =  mocks.tgCurrentUserService.projects.getIn(['all', 0])

        userServiceCheckImmutable = sinon.match ((immutable) ->
            immutable = immutable.toJS()

            return _.isEqual(immutable[0], newProject)
        ), 'userServiceCheckImmutable'

        projectServiceCheckImmutable = sinon.match ((immutable) ->
            immutable = immutable.toJS()

            return _.isEqual(immutable, newProject)
        ), 'projectServiceCheckImmutable'


        likeButtonService.like(projectId).finally () ->
            expect(mocks.tgCurrentUserService.setProjects).to.have.been.calledWith(userServiceCheckImmutable)
            expect(mocks.tgProjectService.setProject).to.have.been.calledWith(projectServiceCheckImmutable)

            done()

    it "like, if the user doesn't have the project", (done) ->
        projectId = 4

        mocks.tgResources.projects.likeProject.withArgs(projectId).promise().resolve()

        newProject = {
            id: 4,
            total_fans: 3,
            is_fan: true
        }

        mocks.tgProjectService.project =  mocks.tgCurrentUserService.projects.getIn(['all', 0])

        mocks.tgCurrentUserService.projects = Immutable.fromJS({
            all: []
        })

        projectServiceCheckImmutable = sinon.match ((immutable) ->
            immutable = immutable.toJS()

            return _.isEqual(immutable, newProject)
        ), 'projectServiceCheckImmutable'


        likeButtonService.like(projectId).finally () ->
            expect(mocks.tgCurrentUserService.setProjects).to.not.have.been.called
            expect(mocks.tgProjectService.setProject).to.have.been.calledWith(projectServiceCheckImmutable)

            done()

    it "unlike", (done) ->
        projectId = 5

        mocks.tgResources.projects.unlikeProject.withArgs(projectId).promise().resolve()

        newProject =  {
            id: 5,
            total_fans: 6,
            is_fan: false
        }

        mocks.tgProjectService.project =  mocks.tgCurrentUserService.projects.getIn(['all', 1])

        userServiceCheckImmutable = sinon.match ((immutable) ->
            immutable = immutable.toJS()

            return _.isEqual(immutable[1], newProject)
        ), 'userServiceCheckImmutable'

        projectServiceCheckImmutable = sinon.match ((immutable) ->
            immutable = immutable.toJS()

            return _.isEqual(immutable, newProject)
        ), 'projectServiceCheckImmutable'


        likeButtonService.unlike(projectId).finally () ->
            expect(mocks.tgCurrentUserService.setProjects).to.have.been.calledWith(userServiceCheckImmutable)
            expect(mocks.tgProjectService.setProject).to.have.been.calledWith(projectServiceCheckImmutable)

            done()
