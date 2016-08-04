###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: epic-row.controller.spec.coffee
###

describe "EpicsDashboard", ->
    EpicsDashboardCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            projects: {
                getBySlug: sinon.stub()
            }
        }

        provide.value "$tgResources", mocks.tgResources

    _mockTgResourcesNew = () ->
        mocks.tgResourcesNew = {
            epics: {
                list: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResourcesNew

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mockRouteParams = () ->
        mocks.routeparams = {
            pslug: sinon.stub()
        }

        provide.value "$routeParams", mocks.routeparams

    _mockTgErrorHandlingService = () ->
        mocks.tgErrorHandlingService = {
            permissionDenied: sinon.stub()
        }

        provide.value "tgErrorHandlingService", mocks.tgErrorHandlingService

    _mockTgLightboxFactory = () ->
        mocks.tgLightboxFactory = {
            create: sinon.stub()
        }

        provide.value "tgLightboxFactory", mocks.tgLightboxFactory

    _mockLightboxService = () ->
        mocks.lightboxService = {
            closeAll: sinon.stub()
        }

        provide.value "lightboxService", mocks.lightboxService

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgResources()
            _mockTgResourcesNew()
            _mockRouteParams()
            _mockTgErrorHandlingService()
            _mockTgLightboxFactory()
            _mockLightboxService()
            _mockTgConfirm()

            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

        EpicsDashboardCtrl = controller "EpicsDashboardCtrl"

    it "load projects", (done) ->
        EpicsDashboardCtrl = controller "EpicsDashboardCtrl"
        params = mocks.routeparams.pslug
        EpicsDashboardCtrl.loadEpics = sinon.stub()
        project = {
            is_epics_activated: false
        }
        promise = mocks.tgResources.projects.getBySlug.withArgs(params).promise().resolve(project)
        EpicsDashboardCtrl.loadProject().then () ->
            expect(mocks.tgErrorHandlingService.permissionDenied).have.been.called
            expect(EpicsDashboardCtrl.project).is.equal(project)
            expect(EpicsDashboardCtrl.loadEpics).have.been.called
            done()

    it "load epics", (done) ->
        EpicsDashboardCtrl = controller "EpicsDashboardCtrl"
        EpicsDashboardCtrl.project = {
            id: 1
        }
        epics = {
            id: 1
        }
        promise = mocks.tgResourcesNew.epics.list.withArgs(EpicsDashboardCtrl.project.id).promise().resolve(epics)
        EpicsDashboardCtrl.loadEpics().then () ->
            expect(EpicsDashboardCtrl.epics).is.equal(epics)
            done()

    it "on create epic", () ->
        EpicsDashboardCtrl = controller "EpicsDashboardCtrl"
        EpicsDashboardCtrl.loadEpics = sinon.stub()
        EpicsDashboardCtrl._onCreateEpic()
        expect(mocks.lightboxService.closeAll).have.been.called
        expect(mocks.tgConfirm.notify).have.been.calledWith("success")
        expect(EpicsDashboardCtrl.loadEpics).have.been.called
