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
# File: projects/create/trello-import/trello-import.controller.spec.coffee
###

describe "TrelloImportCtrl", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockCurrentUserService = ->
        mocks.currentUserService = {
            canAddMembersPrivateProject: sinon.stub()
            canAddMembersPublicProject: sinon.stub()
        }

        $provide.value("tgCurrentUserService", mocks.currentUserService)


    _mockImportProjectService = ->
        mocks.importProjectService = {
            importPromise: sinon.stub()
        }

        $provide.value("tgImportProjectService", mocks.importProjectService)

    _mockTrelloImportService = ->
        mocks.trelloService = {
            fetchProjects: sinon.stub(),
            fetchUsers: sinon.stub(),
            importProject: sinon.stub()
        }

        $provide.value("tgTrelloImportService", mocks.trelloService)

    _mockConfirm = ->
        mocks.confirm = {
            loader: sinon.stub()
        }

        $provide.value("$tgConfirm", mocks.confirm)

    _mockTranslate = ->
        mocks.translate = {
            instant: sinon.stub()
        }

        $provide.value("$translate", mocks.translate)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTrelloImportService()
            _mockConfirm()
            _mockTranslate()
            _mockImportProjectService()
            _mockCurrentUserService()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaProjects"

        _setup()

    it "start project selector", () ->
        ctrl = $controller("TrelloImportCtrl")

        mocks.trelloService.fetchProjects.promise().resolve()

        ctrl.startProjectSelector().then () ->
            expect(ctrl.step).to.be.equal('project-select-trello')
            expect(mocks.trelloService.fetchProjects).have.been.called

    it "on select project reload projects", (done) ->
        project = Immutable.fromJS({
            id: 1,
            name: "project-name"
        })

        mocks.trelloService.fetchUsers.promise().resolve()

        ctrl = $controller("TrelloImportCtrl")

        promise = ctrl.onSelectProject(project)

        expect(ctrl.fetchingUsers).to.be.true

        promise.then () ->
            expect(ctrl.fetchingUsers).to.be.false
            expect(ctrl.step).to.be.equal('project-form-trello')
            expect(ctrl.project).to.be.equal(project)
            done()

    it "on save project details reload users", () ->
        project = Immutable.fromJS({
            id: 1,
            name: "project-name"
        })

        ctrl = $controller("TrelloImportCtrl")
        ctrl.onSaveProjectDetails(project)

        expect(ctrl.step).to.be.equal('project-members-trello')
        expect(ctrl.project).to.be.equal(project)


    it "on select user init import", (done) ->
        users = Immutable.fromJS([
            {
                id: 0
            },
            {
                id: 1
            },
            {
                id: 2
            }
        ])

        loaderObj = {
            start: sinon.spy(),
            update: sinon.stub(),
            stop: sinon.spy()
        }

        projectResult = {
            id: 3,
            name: "name"
        }

        mocks.confirm.loader.returns(loaderObj)

        mocks.importProjectService.importPromise.promise().resolve()

        ctrl = $controller("TrelloImportCtrl")
        ctrl.project = Immutable.fromJS({
            id: 1,
            name: 'project-name',
            description: 'project-description',
            keepExternalReference: false,
            is_private: true
        })


        mocks.trelloService.importProject.promise().resolve(projectResult)

        ctrl.startImport(users).then () ->
            expect(loaderObj.start).have.been.called
            expect(loaderObj.stop).have.been.called
            expect(mocks.trelloService.importProject).have.been.calledWith('project-name', 'project-description', 1, users, false, true)

            done()
