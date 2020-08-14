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
# File: projects/create/jira-import/jira-import.service.spec.coffee
###

describe "tgJiraImportService", ->
    $provide = null
    $rootScope = null
    $q = null
    service = null
    mocks = {}

    _mockResources = ->
        mocks.resources = {
            jiraImporter: {
                listProjects: sinon.stub(),
                listUsers: sinon.stub(),
                importProject: sinon.stub(),
                getAuthUrl: sinon.stub(),
                authorize: sinon.stub()
            }
        }

        $provide.value("tgResources", mocks.resources)

    _mockLocation = ->
        mocks.location = {
            search: sinon.stub()
        }

        mocks.location.search.returns({
            url: "http://test",
            token: 123
        })

        $provide.value("$location", mocks.location)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockResources()
            _mockLocation()

            return null

    _inject = ->
        inject (_tgJiraImportService_, _$rootScope_, _$q_) ->
            service = _tgJiraImportService_
            $rootScope = _$rootScope_
            $q = _$q_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaProjects"

        _setup()

    it "fetch projects", (done) ->
        service.setToken(123, 'http://test')
        mocks.resources.jiraImporter.listProjects.withArgs("http://test", 123).promise().resolve('projects')

        service.fetchProjects().then () ->
            service.projects = "projects"
            done()

    it "fetch user", (done) ->
        service.setToken(123, 'http://test')
        projectId = 3
        mocks.resources.jiraImporter.listUsers.withArgs("http://test", 123, projectId).promise().resolve('users')

        service.fetchUsers(projectId).then () ->
            service.projectUsers = 'users'
            done()

    it "import project", () ->
        service.setToken(123, 'http://test')
        service.url = 'url'
        projectId = 2

        service.importProject(projectId, true, true ,true)

        expect(mocks.resources.jiraImporter.importProject).to.have.been.calledWith('url', 123, projectId, true, true, true)

    it "get auth url", (done) ->
        service.setToken(123, 'http://test')
        projectId = 3

        response = {
            data: {
                url: "url123"
            }
        }

        getAuthUrlDeferred = $q.defer()
        mocks.resources.jiraImporter.getAuthUrl.withArgs("http://test").returns(getAuthUrlDeferred.promise)
        getAuthUrlDeferred.resolve(response)

        service.getAuthUrl('http://test').then (url) ->
            expect(url).to.be.equal("url123")
            done()

        $rootScope.$apply()

    it "authorize", (done) ->
        service.setToken(123, 'http://test')
        projectId = 3

        response = {
            data: {
                url: "http://test",
                token: "token123"
            }
        }

        authorizeDeferred = $q.defer()
        mocks.resources.jiraImporter.authorize.returns(authorizeDeferred.promise)
        authorizeDeferred.resolve(response)

        service.authorize().then (token) ->
            expect(token).to.be.deep.equal({url: "http://test", token: "token123"})
            done()

        $rootScope.$apply()
