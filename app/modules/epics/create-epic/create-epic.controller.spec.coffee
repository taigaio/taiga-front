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
# File: epics/create-epic/create-epic.controller.spec.coffee
###

describe "EpicRow", ->
    createEpicCtrl =  null
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
            project: {
                toJS: sinon.stub()
            }
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mockTgEpicsService = () ->
        mocks.tgEpicsService = {
            createEpic: sinon.stub()
        }
        provide.value "tgEpicsService", mocks.tgEpicsService

    _mockTgAnalytics = ->
        mocks.tgAnalytics = {
            trackEvent: sinon.stub()
        }

        provide.value("$tgAnalytics", mocks.tgAnalytics)

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgConfirm()
            _mockTgProjectService()
            _mockTgEpicsService()
            _mockTgAnalytics()
            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "create Epic with invalid form", () ->
        mocks.tgProjectService.project.toJS.withArgs().returns(
            {id: 1, default_epic_status: 1}
        )

        data = {
            validateForm: sinon.stub()
            setFormErrors: sinon.stub()
            onCreateEpic: sinon.stub()
        }
        createEpicCtrl = controller "CreateEpicCtrl", null, data
        createEpicCtrl.attachments = Immutable.List([{file: "file1"}, {file: "file2"}])

        data.validateForm.withArgs().returns(false)

        createEpicCtrl.createEpic()

        expect(data.validateForm).have.been.called
        expect(mocks.tgEpicsService.createEpic).not.have.been.called

    it "create Epic successfully", (done) ->
        mocks.tgProjectService.project.toJS.withArgs().returns(
            {id: 1, default_epic_status: 1}
        )

        data = {
            validateForm: sinon.stub()
            setFormErrors: sinon.stub()
            onCreateEpic: sinon.stub()
        }
        createEpicCtrl = controller "CreateEpicCtrl", null, data
        createEpicCtrl.attachments = Immutable.List([{file: "file1"}, {file: "file2"}])

        data.validateForm.withArgs().returns(true)
        mocks.tgEpicsService.createEpic
            .withArgs(
                createEpicCtrl.newEpic,
                createEpicCtrl.attachments)
            .promise()
            .resolve(
                {data: {id: 1, project: 1}}
            )

        createEpicCtrl.createEpic().then () ->
            expect(data.validateForm).have.been.called
            expect(createEpicCtrl.onCreateEpic).have.been.called
            done()
