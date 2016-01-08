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
# File: attchments.controller.spec.coffee
###

describe "AttachmentsController", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockAttachmentsService = ->
        mocks.attachmentsService = {
            upload: sinon.stub()
        }

        $provide.value("tgAttachmentsService", mocks.attachmentsService)

    _mockConfirm = ->
        mocks.confirm = {}

        $provide.value("$tgConfirm", mocks.confirm)

    _mockTranslate = ->
        mocks.translate = {
            instant: sinon.stub()
        }

        $provide.value("$translate", mocks.translate)

    _mockConfig = ->
        mocks.config = {
            get: sinon.stub()
        }

        $provide.value("$tgConfig", mocks.config)

    _mockStorage = ->
        mocks.storage = {
            get: sinon.stub()
        }

        $provide.value("$tgStorage", mocks.storage)

    _mockRootScope = ->
        mocks.rootScope = {}

        $provide.value("$rootScope", mocks.rootScope)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockAttachmentsService()
            _mockConfirm()
            _mockTranslate()
            _mockConfig()
            _mockStorage()
            _mockRootScope()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaComponents"

        _setup()

    it "generate, refresh deprecated counter", () ->
        attachments = Immutable.fromJS([
            {
                file: {
                    is_deprecated: false
                }
            },
            {
                file: {
                    is_deprecated: true
                }
            },
            {
                file: {
                    is_deprecated: true
                }
            },
            {
                file: {
                    is_deprecated: false
                }
            },
            {
                file: {
                    is_deprecated: true
                }
            }
        ])

        ctrl = $controller("AttachmentsFull")

        ctrl.attachments = attachments

        ctrl.generate()

        expect(ctrl.deprecatedsCount).to.be.equal(3)

    it "toggle deprecated visibility", () ->
        ctrl = $controller("AttachmentsFull")

        ctrl.deprecatedsVisible = false

        ctrl.generate = sinon.spy()

        ctrl.toggleDeprecatedsVisible()

        expect(ctrl.deprecatedsVisible).to.be.true
        expect(ctrl.generate).to.be.calledOnce

    describe "add attachments", () ->
        it "valid attachment", (done) ->
            file = Immutable.fromJS({
                file: {},
                name: 'test',
                size: 3000
            })

            mocks.attachmentsService.validate = sinon.stub()
            mocks.attachmentsService.validate.withArgs(file).returns(true)

            mocks.attachmentsService.upload = sinon.stub()
            mocks.attachmentsService.upload.promise().resolve(file)

            mocks.rootScope.$broadcast = sinon.spy()

            ctrl = $controller("AttachmentsFull")
            ctrl.attachments = Immutable.List()

            ctrl.addAttachment(file).then () ->
                expect(mocks.rootScope.$broadcast).have.been.calledWith('attachment:create')
                expect(ctrl.attachments.count()).to.be.equal(1)
                done()

        it "invalid attachment", () ->
            file = Immutable.fromJS({
                file: {},
                name: 'test',
                size: 3000
            })

            mocks.attachmentsService.validate = sinon.stub()
            mocks.attachmentsService.validate.withArgs(file).returns(false)

            mocks.attachmentsService.upload = sinon.stub()
            mocks.attachmentsService.upload.promise().resolve(file)

            mocks.rootScope.$broadcast = sinon.spy()

            ctrl = $controller("AttachmentsFull")

            ctrl.attachments = Immutable.List()

            ctrl.addAttachment(file).then null, () ->
                expect(ctrl.attachments.count()).to.be.equal(0)

    it "add attachments", () ->
        ctrl = $controller("AttachmentsFull")

        ctrl.attachments = Immutable.List()
        ctrl.addAttachment = sinon.spy()

        files = [
            {},
            {},
            {}
        ]

        ctrl.addAttachments(files)

        expect(ctrl.addAttachment).to.have.callCount(3)

    describe "deleteattachments", () ->
        it "success attachment", (done) ->
            askResponse = {
                finish: sinon.spy()
            }

            mocks.translate.instant.withArgs('ATTACHMENT.TITLE_LIGHTBOX_DELETE_ATTACHMENT').returns('title')
            mocks.translate.instant.withArgs('ATTACHMENT.MSG_LIGHTBOX_DELETE_ATTACHMENT').returns('message')

            mocks.confirm.askOnDelete = sinon.stub()
            mocks.confirm.askOnDelete.withArgs('title', 'message').promise().resolve(askResponse)

            mocks.attachmentsService.delete = sinon.stub()
            mocks.attachmentsService.delete.withArgs('us', 2).promise().resolve()

            ctrl = $controller("AttachmentsFull")

            ctrl.type = 'us'
            ctrl.generate = sinon.spy()
            ctrl.attachments = Immutable.fromJS([
                {
                    file: {id: 1}
                },
                {
                    file: {id: 2}
                },
                {
                    file: {id: 3}
                },
                {
                    file: {id: 4}
                }
            ])

            deleteFile = ctrl.attachments.get(1)

            ctrl.deleteAttachment(deleteFile).then () ->
                expect(ctrl.generate).have.been.calledOnce
                expect(ctrl.attachments.size).to.be.equal(3)
                expect(askResponse.finish).have.been.calledOnce
                done()

        it "error attachment", (done) ->
            askResponse = {
                finish: sinon.spy()
            }

            mocks.translate.instant.withArgs('ATTACHMENT.TITLE_LIGHTBOX_DELETE_ATTACHMENT').returns('title')
            mocks.translate.instant.withArgs('ATTACHMENT.MSG_LIGHTBOX_DELETE_ATTACHMENT').returns('message')
            mocks.translate.instant.withArgs('ATTACHMENT.ERROR_DELETE_ATTACHMENT').returns('error')

            mocks.confirm.askOnDelete = sinon.stub()
            mocks.confirm.askOnDelete.withArgs('title', 'message').promise().resolve(askResponse)

            mocks.confirm.notify = sinon.spy()

            mocks.attachmentsService.delete = sinon.stub()
            mocks.attachmentsService.delete.promise().reject()

            ctrl = $controller("AttachmentsFull")

            ctrl.type = 'us'
            ctrl.generate = sinon.spy()
            ctrl.attachments = Immutable.fromJS([
                {
                    file: {id: 1}
                },
                {
                    file: {id: 2}
                },
                {
                    file: {id: 3}
                },
                {
                    file: {id: 4}
                }
            ])

            deleteFile = ctrl.attachments.get(1)

            ctrl.deleteAttachment(deleteFile).then () ->
                expect(ctrl.attachments.size).to.be.equal(4)
                expect(askResponse.finish.withArgs(false)).have.been.calledOnce
                expect(mocks.confirm.notify.withArgs('error', null, 'error'))
                done()

    it "reorder attachments", (done) ->
        attachments = Immutable.fromJS([
            {file: {id: 0, is_deprecated: false, order: 0}},
            {file: {id: 1, is_deprecated: true, order: 1}},
            {file: {id: 2, is_deprecated: true, order: 2}},
            {file: {id: 3, is_deprecated: false, order: 3}},
            {file: {id: 4, is_deprecated: true, order: 4}}
        ])

        mocks.attachmentsService.patch = sinon.stub()
        mocks.attachmentsService.patch.promise().resolve()

        ctrl = $controller("AttachmentsFull")

        ctrl.type = 'us'
        ctrl.attachments = attachments

        ctrl.reorderAttachment(attachments.get(1), 0).then () ->
            expect(ctrl.attachments.get(0)).to.be.equal(attachments.get(1))
            done()

    it "update attachment", () ->
        attachments = Immutable.fromJS([
            {file: {id: 0, is_deprecated: false, order: 0}},
            {file: {id: 1, is_deprecated: true, order: 1}},
            {file: {id: 2, is_deprecated: true, order: 2}},
            {file: {id: 3, is_deprecated: false, order: 3}},
            {file: {id: 4, is_deprecated: true, order: 4}}
        ])

        attachment = attachments.get(1)
        attachment = attachment.setIn(['file', 'is_deprecated'], false)

        mocks.attachmentsService.patch = sinon.stub()
        mocks.attachmentsService.patch.withArgs(1, 'us', {is_deprecated: false}).promise().resolve()

        ctrl = $controller("AttachmentsFull")

        ctrl.type = 'us'
        ctrl.attachments = attachments

        ctrl.updateAttachment(attachment).then () ->
            expect(ctrl.attachments.get(1).toJS()).to.be.eql(attachment.toJS())
