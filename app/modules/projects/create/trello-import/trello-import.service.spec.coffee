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
# File: projects/create/trello-import/trello-import.service.spec.coffee
###

describe "tgTrelloImportService", ->
    $provide = null
    service = null
    mocks = {}

    _mockResources = ->
        mocks.resources = {
            trelloImporter: {
                listProjects: sinon.stub(),
                listUsers: sinon.stub(),
                importProject: sinon.stub(),
                getAuthUrl: sinon.stub(),
                authorize: sinon.stub()
            }
        }

        $provide.value("tgResources", mocks.resources)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockResources()

            return null

    _inject = ->
        inject (_tgTrelloImportService_) ->
            service = _tgTrelloImportService_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaProjects"

        _setup()

    it "fetch projects", (done) ->
        service.setToken(123)
        mocks.resources.trelloImporter.listProjects.withArgs(123).promise().resolve('projects')

        service.fetchProjects().then () ->
            service.projects = "projects"
            done()

    it "fetch user", (done) ->
        service.setToken(123)
        projectId = 3
        mocks.resources.trelloImporter.listUsers.withArgs(123, projectId).promise().resolve('users')

        service.fetchUsers(projectId).then () ->
            service.projectUsers = 'users'
            done()

    it "import project", () ->
        service.setToken(123)
        projectId = 2

        service.importProject(projectId, true, true ,true)

        expect(mocks.resources.trelloImporter.importProject).to.have.been.calledWith(123, projectId, true, true, true)

    it "get auth url", (done) ->
        service.setToken(123)
        projectId = 3

        response = {
            data: {
                url: "url123"
            }
        }

        mocks.resources.trelloImporter.getAuthUrl.promise().resolve(response)

        service.getAuthUrl().then (url) ->
            expect(url).to.be.equal("url123")
            done()

    it "authorize", (done) ->
        service.setToken(123)
        projectId = 3
        verifyCode = 12345

        response = {
            data: {
                token: "token123"
            }
        }

        mocks.resources.trelloImporter.authorize.withArgs(verifyCode).promise().resolve(response)

        service.authorize(verifyCode).then (token) ->
            expect(token).to.be.equal("token123")
            done()
