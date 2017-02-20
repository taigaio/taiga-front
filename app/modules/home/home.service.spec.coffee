###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: home.service.spec.coffee
###

describe "tgHome", ->
    homeService = provide = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.epics = {}
        mocks.resources.userstories = {}
        mocks.resources.tasks = {}
        mocks.resources.issues = {}

        mocks.resources.epics.listInAllProjects = sinon.stub()
        mocks.resources.userstories.listInAllProjects = sinon.stub()
        mocks.resources.tasks.listInAllProjects = sinon.stub()
        mocks.resources.issues.listInAllProjects = sinon.stub()

        provide.value "tgResources", mocks.resources

    _mockTgNavUrls = () ->
        mocks.tgNavUrls = {
            resolve: sinon.stub()
        }

        provide.value "$tgNavUrls", mocks.tgNavUrls

    _mockProjectsService = () ->
        mocks.projectsService = {
            getProjectsByUserId: sinon.stub().promise()
        }

        provide.value "tgProjectsService", mocks.projectsService

    _inject = (callback) ->
        inject (_tgHomeService_) ->
            homeService = _tgHomeService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()
            _mockTgNavUrls()
            _mockProjectsService()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaHome"
        _setup()
        _inject()

    it "get work in progress by user", (done) ->
        userId = 3

        project1 = {id: 1, name: "fake1", slug: "project-1"}
        project2 = {id: 2, name: "fake2", slug: "project-2"}

        mocks.projectsService.getProjectsByUserId
            .withArgs(userId)
            .resolve(Immutable.fromJS([
                project1,
                project2
            ]))

        mocks.resources.epics.listInAllProjects
            .withArgs(sinon.match({
                status__is_closed: false
                assigned_to: userId
            }))
            .promise()
            .resolve(Immutable.fromJS([{id: 4, ref: 4, project: "1"}]))

        mocks.resources.epics.listInAllProjects
            .withArgs(sinon.match({
                status__is_closed: false
                watchers: userId
            }))
            .promise()
            .resolve(Immutable.fromJS([
                {id: 4, ref: 4, project: "1"},
                {id: 5, ref: 5, project: "10"} # the user is not member of this project
            ]))

        mocks.resources.userstories.listInAllProjects
            .withArgs(sinon.match({
                is_closed: false
                assigned_to: userId
            }))
            .promise()
            .resolve(Immutable.fromJS([{id: 1, ref: 1, project: "1"}]))

        mocks.resources.userstories.listInAllProjects
            .withArgs(sinon.match({
                is_closed: false
                watchers: userId
            }))
            .promise()
            .resolve(Immutable.fromJS([
                {id: 1, ref: 1, project: "1"},
                {id: 2, ref: 2, project: "10"} # the user is not member of this project
            ]))

        mocks.resources.tasks.listInAllProjects.promise()
            .resolve(Immutable.fromJS([{id: 2, ref: 2, project: "1"}]))

        mocks.resources.issues.listInAllProjects.promise()
            .resolve(Immutable.fromJS([{id: 3, ref: 3, project: "1"}]))

        # mock urls
        mocks.tgNavUrls.resolve
            .withArgs("project-epics-detail", {project: "project-1", ref: 4})
            .returns("/testing-project/epic/1")

        mocks.tgNavUrls.resolve
            .withArgs("project-userstories-detail", {project: "project-1", ref: 1})
            .returns("/testing-project/us/1")

        mocks.tgNavUrls.resolve
            .withArgs("project-tasks-detail", {project: "project-1", ref: 2})
            .returns("/testing-project/tasks/1")

        mocks.tgNavUrls.resolve
            .withArgs("project-issues-detail", {project: "project-1", ref: 3})
            .returns("/testing-project/issues/1")

        homeService.getWorkInProgress(userId)
            .then (workInProgress) ->
                expect(workInProgress.toJS()).to.be.eql({
                    assignedTo: {
                        epics: [{
                            id: 4,
                            ref: 4,
                            url: '/testing-project/epic/1',
                            project: project1,
                            _name: 'epics'
                        }]
                        userStories: [{
                            id: 1,
                            ref: 1,
                            url: '/testing-project/us/1',
                            project: project1,
                            _name: 'userstories'
                        }]
                        tasks: [{
                            id: 2,
                            ref: 2,
                            project: project1,
                            url: '/testing-project/tasks/1',
                            _name: 'tasks'
                        }]
                        issues: [{
                            id: 3,
                            ref: 3,
                            url: '/testing-project/issues/1',
                            project: project1,
                            _name: 'issues'
                        }]
                    }
                    watching: {
                        epics: [{
                            id: 4,
                            ref: 4,
                            url: '/testing-project/epic/1',
                            project: project1,
                            _name: 'epics'
                        }]
                        userStories: [{
                            id: 1,
                            ref: 1,
                            url: '/testing-project/us/1',
                            project: project1,
                            _name: 'userstories'
                        }]
                        tasks: [{
                            id: 2,
                            ref: 2,
                            url: '/testing-project/tasks/1',
                            project: project1,
                            _name: 'tasks'
                        }]
                        issues: [{
                            id: 3,
                            ref: 3,
                            url: '/testing-project/issues/1',
                            project: project1,
                            _name: 'issues'
                        }]
                    }
                })

                done()
