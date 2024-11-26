###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgAttachmentsFullService", ->
    $provide = null
    $q = null
    attachmentsFullService = null
    mocks = {}

    _mockAttachmentsService = ->
        mocks.attachmentsService = {
            upload: sinon.stub()
        }

        $provide.value("tgAttachmentsService", mocks.attachmentsService)

    _mockRootScope = ->
        mocks.rootScope = {
            $evalAsync: (cb) -> cb()
        }

        $provide.value("$rootScope", mocks.rootScope)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockAttachmentsService()
            _mockRootScope()

            return null

    _inject = ->
        inject (_tgAttachmentsFullService_, _$q_) ->
            attachmentsFullService = _tgAttachmentsFullService_
            $q = _$q_

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

        attachmentsFullService._attachments = attachments

        attachmentsFullService.regenerate()

        expect(attachmentsFullService._deprecatedsCount).to.be.equal(3)

    it "toggle deprecated visibility", () ->
        attachmentsFullService._deprecatedsVisible = false

        attachmentsFullService.regenerate = sinon.spy()

        attachmentsFullService.toggleDeprecatedsVisible()

        expect(attachmentsFullService.deprecatedsVisible).to.be.true
        expect(attachmentsFullService.regenerate).to.be.calledOnce

    describe "add attachments", () ->
        it "valid attachment", (done) ->
            projectId = 1
            objId = 2
            type = "issue"

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

            attachmentsFullService._attachments = Immutable.List()

            attachmentsFullService.addAttachment(projectId, objId, type, file).then () ->
                expect(mocks.rootScope.$broadcast).have.been.calledWith('attachment:create')
                expect(attachmentsFullService.attachments.count()).to.be.equal(1)
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

            attachmentsFullService._attachments = Immutable.List()

            attachmentsFullService.addAttachment(file).then null, () ->
                expect(attachmentsFullService._attachments.count()).to.be.equal(0)

    describe "deleteattachments", () ->
        it "success attachment", (done) ->
            mocks.attachmentsService.delete = sinon.stub()
            mocks.attachmentsService.delete.withArgs('us', 2).promise().resolve()

            attachmentsFullService.regenerate = sinon.spy()
            attachmentsFullService._attachments = Immutable.fromJS([
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

            deleteFile = attachmentsFullService._attachments.get(1)

            attachmentsFullService.deleteAttachment(deleteFile, 'us').then () ->
                expect(attachmentsFullService.regenerate).have.been.calledOnce
                expect(attachmentsFullService.attachments.size).to.be.equal(3)
                done()

    it "reorder attachments", (done) ->
        deferred = $q.defer();
        attachments = Immutable.fromJS([
            {file: {id: 0, is_deprecated: false, order: 0, is_deprecated: false}},
            {file: {id: 1, is_deprecated: true, order: 1, is_deprecated: false}},
            {file: {id: 2, is_deprecated: true, order: 2, is_deprecated: false}},
            {file: {id: 3, is_deprecated: false, order: 3, is_deprecated: false}},
            {file: {id: 4, is_deprecated: true, order: 4, is_deprecated: false}}
        ])

        mocks.attachmentsService.bulkUpdateOrder = sinon.stub()
        mocks.attachmentsService.bulkUpdateOrder.returns(deferred.promise)
        deferred.resolve()

        attachmentsFullService._attachments = attachments

        attachmentsFullService.reorderAttachment(1, 'us', attachments.get(1), 0).then () ->
            expect(attachmentsFullService.attachments.get(0)).to.be.equal(attachments.get(1))
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

        attachmentsFullService._attachments = attachments

        attachmentsFullService.updateAttachment(attachment, 'us').then () ->
            expect(attachmentsFullService.attachments.get(1).toJS()).to.be.eql(attachment.toJS())

    it "update loading attachment", () ->
        attachments = Immutable.fromJS([
            {file: {id: 0, is_deprecated: false, order: 0}},
            {loading: true, file: {id: 1, is_deprecated: true, order: 1}},
            {file: {id: 2, is_deprecated: true, order: 2}},
            {file: {id: 3, is_deprecated: false, order: 3}},
            {file: {id: 4, is_deprecated: true, order: 4}}
        ])

        attachment = attachments.get(1)
        attachment = attachment.setIn(['file', 'is_deprecated'], false)

        mocks.attachmentsService.patch = sinon.stub()
        mocks.attachmentsService.patch.withArgs(1, 'us', {is_deprecated: false}).promise().resolve()

        attachmentsFullService._attachments = attachments

        attachmentsFullService.updateAttachment(attachment, 'us')

        expect(attachmentsFullService.attachments.get(1).toJS()).to.be.eql(attachment.toJS())
