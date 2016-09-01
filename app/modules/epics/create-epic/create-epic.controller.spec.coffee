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

describe "EpicRow", ->
    createEpicCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            epics: {
                post: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResources

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }
        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgAttachmentsService = () ->
        mocks.tgAttachmentsService = {
            upload: sinon.stub()
        }
        provide.value "tgAttachmentsService", mocks.tgAttachmentsService

    _mockQ = () ->
        mocks.q = {
            all: sinon.spy()
        }

        provide.value "$q", mocks.q


    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgResources()
            _mockTgConfirm()
            _mockTgAttachmentsService()
            _mockQ()
            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "create Epic with invalid form", () ->
        data = {
            project: {id: 1, default_epic_status: 1}
            validateForm: sinon.stub()
            setFormErrors: sinon.stub()
            onCreateEpic: sinon.stub()
        }
        createEpicCtrl = controller "CreateEpicCtrl", null, data
        createEpicCtrl.attachments = Immutable.List([{file: "file1"}, {file: "file2"}])

        data.validateForm.withArgs().returns(false)

        createEpicCtrl.createEpic()

        expect(data.validateForm).have.been.called
        expect(mocks.tgResources.epics.post).not.have.been.called

    it "create Epic successfully", (done) ->
        data = {
            project: {id: 1, default_epic_status: 1}
            validateForm: sinon.stub()
            setFormErrors: sinon.stub()
            onCreateEpic: sinon.stub()
        }
        createEpicCtrl = controller "CreateEpicCtrl", null, data
        createEpicCtrl.attachments = Immutable.List([{file: "file1"}, {file: "file2"}])

        data.validateForm.withArgs().returns(true)
        mocks.tgResources.epics.post.withArgs(createEpicCtrl.newEpic).promise().resolve(
            {data: {id: 1, project: 1}}
        )

        createEpicCtrl.createEpic().then () ->
            expect(data.validateForm).have.been.called
            expect(mocks.tgAttachmentsService.upload).have.been.calledTwice
            expect(createEpicCtrl.onCreateEpic).have.been.called
            done()
