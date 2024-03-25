###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "GithubImportCtrl", ->
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

    _mockGithubImportService = ->
        mocks.githubService = {
            fetchProjects: sinon.stub(),
            fetchUsers: sinon.stub(),
            importProject: sinon.stub()
        }

        $provide.value("tgGithubImportService", mocks.githubService)

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

            _mockGithubImportService()
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
        ctrl = $controller("GithubImportCtrl")
        ctrl.startProjectSelector()

        expect(ctrl.step).to.be.equal('project-select-github')
        expect(mocks.githubService.fetchProjects).have.been.called

    it "on select project reload projects", (done) ->
        project = Immutable.fromJS({
            id: 1,
            name: "project-name"
        })

        mocks.githubService.fetchUsers.promise().resolve()

        ctrl = $controller("GithubImportCtrl")

        promise = ctrl.onSelectProject(project)

        expect(ctrl.fetchingUsers).to.be.true

        promise.then () ->
            expect(ctrl.fetchingUsers).to.be.false
            expect(ctrl.step).to.be.equal('project-form-github')
            expect(ctrl.project).to.be.equal(project)
            done()

    it "on save project details reload users", () ->
        project = Immutable.fromJS({
            id: 1,
            name: "project-name"
        })

        ctrl = $controller("GithubImportCtrl")
        ctrl.onSaveProjectDetails(project)

        expect(ctrl.step).to.be.equal('project-members-github')
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

        ctrl = $controller("GithubImportCtrl")
        ctrl.project = Immutable.fromJS({
            id: 1,
            name: 'project-name',
            description: 'project-description',
            keepExternalReference: false,
            is_private: true
        })


        mocks.githubService.importProject.promise().resolve(projectResult)

        ctrl.startImport(users).then () ->
            expect(loaderObj.start).have.been.called
            expect(loaderObj.stop).have.been.called
            expect(mocks.githubService.importProject).have.been.calledWith('project-name', 'project-description', 1, users, false, true)

            done()
