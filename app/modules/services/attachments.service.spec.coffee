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
# File: services/attachments.service.spec.coffee
###

describe "tgAttachmentsService", ->
    attachmentsService = provide = null
    mocks = {}

    _mockTgConfirm = () ->
        mocks.confirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.confirm

    _mockTgConfig = () ->
        mocks.config = {
            get: sinon.stub()
        }

        mocks.config.get.withArgs('maxUploadFileSize', null).returns(3000)

        provide.value "$tgConfig", mocks.config

    _mockRs = () ->
        mocks.rs = {}

        provide.value "tgResources", mocks.rs

    _mockTranslate = () ->
        mocks.translate = {
            instant: sinon.stub()
        }

        provide.value "$translate", mocks.translate


    _inject = (callback) ->
        inject (_tgAttachmentsService_) ->
            attachmentsService = _tgAttachmentsService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgConfirm()
            _mockTgConfig()
            _mockRs()
            _mockTranslate()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaCommon"
        _setup()
        _inject()

    it "maxFileSize formated", () ->
        expect(attachmentsService.maxFileSizeFormated).to.be.equal("2.9 KB")

    it "sizeError, send notification", () ->
        file = {
            name: 'test',
            size: 3000
        }

        mocks.translate.instant.withArgs('ATTACHMENT.ERROR_MAX_SIZE_EXCEEDED').returns('message')

        attachmentsService.sizeError(file)

        expect(mocks.confirm.notify).to.have.been.calledWith('error', 'message')

    it "invalid, validate", () ->
        file = {
            name: 'test',
            size: 4000
        }

        result = attachmentsService.validate(file)

        expect(result).to.be.false

    it "valid, validate", () ->
        file = {
            name: 'test',
            size: 1000
        }

        result = attachmentsService.validate(file)

        expect(result).to.be.true

    it "get max file size", () ->
        result = attachmentsService.getMaxFileSize()

        expect(result).to.be.equal(3000)

    it "delete", () ->
        mocks.rs.attachments = {
            delete: sinon.stub()
        }

        attachmentsService.delete('us', 2)

        expect(mocks.rs.attachments.delete).to.have.been.calledWith('us', 2)

     it "upload", (done) ->
        file = {
            id: 1
        }

        objId = 2
        projectId = 2
        type = 'us'

        mocks.rs.attachments = {
            create: sinon.stub().promise()
        }

        mocks.rs.attachments.create.withArgs('us', type, objId, file).resolve()

        attachmentsService.sizeError = sinon.spy()

        attachmentsService.upload(file, objId, projectId, 'us').then () ->
            expect(mocks.rs.attachments.create).to.have.been.calledOnce
            done()

    it "patch", (done) ->
        file = {
            id: 1
        }

        objId = 2
        type = 'us'

        patch = {
            id: 2
        }

        mocks.rs.attachments = {
            patch: sinon.stub().promise()
        }

        mocks.rs.attachments.patch.withArgs('us', objId, patch).resolve()

        attachmentsService.sizeError = sinon.spy()

        attachmentsService.patch(objId, 'us', patch).then () ->
            expect(mocks.rs.attachments.patch).to.have.been.calledOnce
            done()

    it "error", () ->
        mocks.translate.instant.withArgs("ATTACHMENT.ERROR_MAX_SIZE_EXCEEDED").returns("msg")

        attachmentsService.sizeError({
            name: 'name',
            size: 123
        })

        expect(mocks.confirm.notify).to.have.been.calledWith('error', 'msg')
