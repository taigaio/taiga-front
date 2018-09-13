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
# File: projects/components/watch-project-button/watch-project-button.service.spec.coffee
###

describe "tgWatchProjectButtonService", ->
    watchButtonService = null
    provide = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            projects: {
                watchProject: sinon.stub(),
                unwatchProject: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResources

    _mockTgCurrentUserService = () ->
        mocks.tgCurrentUserService = {
            setProjects: sinon.stub(),
            getUser: () ->
                return Immutable.fromJS({
                    id: 89
                })
            projects: Immutable.fromJS({
                all: [
                    {
                        id: 4,
                        total_watchers: 0,
                        is_watcher: false,
                        notify_level: null
                    },
                    {
                        id: 5,
                        total_watchers: 1,
                        is_watcher: true,
                        notify_level: 3
                    },
                    {
                        id: 6,
                        total_watchers: 0,
                        is_watcher: true,
                        notify_level: null
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
        inject (_tgWatchProjectButtonService_) ->
            watchButtonService = _tgWatchProjectButtonService_
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

    it "watch", (done) ->
        projectId = 4
        notifyLevel = 3

        mocks.tgResources.projects.watchProject.withArgs(projectId, notifyLevel).promise().resolve()

        newProject = {
            id: 4,
            total_watchers: 1,
            is_watcher: true,
            notify_level: notifyLevel
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


        watchButtonService.watch(projectId, notifyLevel).finally () ->
            expect(mocks.tgCurrentUserService.setProjects).to.have.been.calledWith(userServiceCheckImmutable)
            expect(mocks.tgProjectService.setProject).to.have.been.calledWith(projectServiceCheckImmutable)

            done()

    it "watch, if the user doesn't have the projects", (done) ->
        projectId = 4
        notifyLevel = 3

        mocks.tgResources.projects.watchProject.withArgs(projectId, notifyLevel).promise().resolve()

        newProject = {
            id: 4,
            total_watchers: 1,
            is_watcher: true,
            notify_level: notifyLevel
        }

        mocks.tgProjectService.project =  mocks.tgCurrentUserService.projects.getIn(['all', 0])
        mocks.tgCurrentUserService.projects = Immutable.fromJS({
            all: []
        })

        projectServiceCheckImmutable = sinon.match ((immutable) ->
            immutable = immutable.toJS()

            return _.isEqual(immutable, newProject)
        ), 'projectServiceCheckImmutable'


        watchButtonService.watch(projectId, notifyLevel).finally () ->
            expect(mocks.tgCurrentUserService.setProjects).to.not.have.been.called
            expect(mocks.tgProjectService.setProject).to.have.been.calledWith(projectServiceCheckImmutable)

            done()

    it "watch another option", (done) ->
        projectId = 5
        notifyLevel = 3

        mocks.tgResources.projects.watchProject.withArgs(projectId, notifyLevel).promise().resolve()

        newProject = {
            id: 5,
            total_watchers: 1,
            is_watcher: true,
            notify_level: notifyLevel
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


        watchButtonService.watch(projectId, notifyLevel).finally () ->
            expect(mocks.tgCurrentUserService.setProjects).to.have.been.calledWith(userServiceCheckImmutable)
            expect(mocks.tgProjectService.setProject).to.have.been.calledWith(projectServiceCheckImmutable)

            done()

    it "unwatch", (done) ->
        projectId = 5

        mocks.tgResources.projects.unwatchProject.withArgs(projectId).promise().resolve()

        newProject = {
            id: 5,
            total_watchers: 0,
            is_watcher: false,
            notify_level: null
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


        watchButtonService.unwatch(projectId).finally () ->
            expect(mocks.tgCurrentUserService.setProjects).to.have.been.calledWith(userServiceCheckImmutable)
            expect(mocks.tgProjectService.setProject).to.have.been.calledWith(projectServiceCheckImmutable)

            done()
