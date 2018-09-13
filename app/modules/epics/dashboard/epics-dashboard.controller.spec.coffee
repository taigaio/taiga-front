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
# File: epics/dashboard/epics-dashboard.controller.spec.coffee
###

describe "EpicsDashboard", ->
    provide = null
    controller = null
    mocks = {}

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }
        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            setProjectBySlug: sinon.stub()
            hasPermission: sinon.stub()
            isEpicsDashboardEnabled: sinon.stub()
            project: Immutable.Map({
                "name": "testing name"
                "description": "testing description"
            })
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mockTgEpicsService = () ->
        mocks.tgEpicsService = {
            clear: sinon.stub()
            fetchEpics: sinon.stub()
        }
        provide.value "tgEpicsService", mocks.tgEpicsService

    _mockRouteParams = () ->
        mocks.routeParams = {
            pslug: sinon.stub()
        }

        provide.value "$routeParams", mocks.routeParams

    _mockTgErrorHandlingService = () ->
        mocks.tgErrorHandlingService = {
            permissionDenied: sinon.stub()
            notFound: sinon.stub()
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

    _mockTgAppMetaService = () ->
        mocks.tgAppMetaService = {
            setfn: sinon.stub()
        }

        provide.value "tgAppMetaService", mocks.tgAppMetaService

    _mockTranslate = () ->
        mocks.translate = sinon.stub()

        provide.value "$translate", mocks.translate

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgConfirm()
            _mockTgProjectService()
            _mockTgEpicsService()
            _mockRouteParams()
            _mockTgErrorHandlingService()
            _mockTgLightboxFactory()
            _mockLightboxService()
            _mockTgAppMetaService()
            _mockTranslate()

            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "metada is set", () ->
        ctrl = controller("EpicsDashboardCtrl")
        expect(mocks.tgAppMetaService.setfn).have.been.called

    it "load data because epics panel is enabled and user has permissions", (done) ->
        ctrl = controller("EpicsDashboardCtrl")

        mocks.tgProjectService.setProjectBySlug
            .promise()
            .resolve("ok")
        mocks.tgProjectService.hasPermission
            .returns(true)
        mocks.tgProjectService.isEpicsDashboardEnabled
            .returns(true)

        ctrl.loadInitialData().then () ->
            expect(mocks.tgErrorHandlingService.permissionDenied).not.have.been.called
            expect(mocks.tgErrorHandlingService.notFound).not.have.been.called
            expect(mocks.tgEpicsService.fetchEpics).have.been.called
            done()

    it "not load data because epics panel is not enabled", (done) ->
        ctrl = controller("EpicsDashboardCtrl")

        mocks.tgProjectService.setProjectBySlug
            .promise()
            .resolve("ok")
        mocks.tgProjectService.hasPermission
            .returns(true)
        mocks.tgProjectService.isEpicsDashboardEnabled
            .returns(false)

        ctrl.loadInitialData().then () ->
            expect(mocks.tgErrorHandlingService.permissionDenied).not.have.been.called
            expect(mocks.tgErrorHandlingService.notFound).have.been.called
            expect(mocks.tgEpicsService.fetchEpics).not.have.been.called
            done()

    it "not load data because user has not permissions", (done) ->
        ctrl = controller("EpicsDashboardCtrl")

        mocks.tgProjectService.setProjectBySlug
            .promise()
            .resolve("ok")
        mocks.tgProjectService.hasPermission
            .returns(false)
        mocks.tgProjectService.isEpicsDashboardEnabled
            .returns(true)

        ctrl.loadInitialData().then () ->
            expect(mocks.tgErrorHandlingService.permissionDenied).have.been.called
            expect(mocks.tgErrorHandlingService.notFound).not.have.been.called
            expect(mocks.tgEpicsService.fetchEpics).not.have.been.called
            done()

    it "not load data because epics panel is not enabled and user has not permissions", (done) ->
        ctrl = controller("EpicsDashboardCtrl")

        mocks.tgProjectService.setProjectBySlug
            .promise()
            .resolve("ok")
        mocks.tgProjectService.hasPermission
            .returns(false)
        mocks.tgProjectService.isEpicsDashboardEnabled
            .returns(false)

        ctrl.loadInitialData().then () ->
            expect(mocks.tgErrorHandlingService.permissionDenied).not.have.been.called
            expect(mocks.tgErrorHandlingService.notFound).have.been.called
            expect(mocks.tgEpicsService.fetchEpics).not.have.been.called
            done()
