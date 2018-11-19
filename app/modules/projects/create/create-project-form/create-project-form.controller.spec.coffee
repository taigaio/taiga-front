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
# File: projects/create/create-project-form/create-project-form.controller.spec.coffee
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

        ctrl.projectForm = 'form'

        mocks.projectsService.create.withArgs('form').promise().resolve(Immutable.fromJS({slug: 'project1', id: 1}))
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
