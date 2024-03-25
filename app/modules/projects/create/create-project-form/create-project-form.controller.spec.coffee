###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "CreateProjectFormCtrl", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockNavUrlsService = ->
        mocks.navUrls = {
            resolve: sinon.stub()
        }

        $provide.value("$tgNavUrls", mocks.navUrls)

    _mockCurrentUserService = ->
        mocks.currentUserService = {
            canCreatePublicProjects: sinon.stub().returns({valid: true}),
            canCreatePrivateProjects: sinon.stub().returns({valid: true}),
            loadProjects: sinon.stub()
        }

        $provide.value("tgCurrentUserService", mocks.currentUserService)

    _mockProjectsService = ->
        mocks.projectsService = {
            create: sinon.stub()
        }

        $provide.value("tgProjectsService", mocks.projectsService)

    _mockProjectUrl = ->
        mocks.projectUrl = {
            get: sinon.stub()
        }

        $provide.value("$projectUrl", mocks.projectUrl)

    _mockLocation = ->
        mocks.location = {
            url: sinon.stub()
        }

        $provide.value("$location", mocks.location)

    _mockTgAnalytics = ->
        mocks.tgAnalytics = {
            trackEvent: sinon.stub()
        }

        $provide.value("$tgAnalytics", mocks.tgAnalytics)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockCurrentUserService()
            _mockProjectsService()
            _mockProjectUrl()
            _mockLocation()
            _mockNavUrlsService()
            _mockTgAnalytics()

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

    it "submit project form", () ->
        ctrl = $controller("CreateProjectFormCtrl")

        ctrl.projectForm = {
            name: 'name',
            description: 'description'
        }

        mocks.projectsService.create.withArgs(ctrl.projectForm).promise().resolve(Immutable.fromJS({slug: 'project1', id: 1, name: 'name', description: 'description'}))
        mocks.projectUrl.get.returns('project-url')

        ctrl.submit().then () ->
            expect(ctrl.formSubmitLoading).to.be.true

            expect(mocks.location.url).to.have.been.calledWith('project-url')

    it 'check if the user can create a private projects', () ->
        mocks.currentUserService.canCreatePrivateProjects = sinon.stub().returns({valid: true})

        ctrl = $controller("CreateProjectFormCtrl")

        ctrl.projectForm = {
            is_private: true
        }

        expect(ctrl.canCreateProject()).to.be.true

        mocks.currentUserService.canCreatePrivateProjects = sinon.stub().returns({valid: false})

        ctrl = $controller("CreateProjectFormCtrl")

        ctrl.projectForm = {
            is_private: true
        }

        expect(ctrl.canCreateProject()).to.be.false

    it 'check if the user can create a public projects', () ->
        mocks.currentUserService.canCreatePublicProjects = sinon.stub().returns({valid: true})

        ctrl = $controller("CreateProjectFormCtrl")

        ctrl.projectForm = {
            is_private: false
        }

        expect(ctrl.canCreateProject()).to.be.true

        mocks.currentUserService.canCreatePublicProjects = sinon.stub().returns({valid: false})

        ctrl = $controller("CreateProjectFormCtrl")

        ctrl.projectForm = {
            is_private: false
        }

        expect(ctrl.canCreateProject()).to.be.false
