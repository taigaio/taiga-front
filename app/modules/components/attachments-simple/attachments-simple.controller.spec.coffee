###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "AttachmentsSimple", ->
    $provide = null
    $controller = null
    mocks = {}
    scope = null

    _mockAttachmentsService = ->
        mocks.attachmentsService = {}

        $provide.value("tgAttachmentsService", mocks.attachmentsService)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockAttachmentsService()

            return null

    _inject = ->
        inject (_$controller_, $rootScope) ->
            $controller = _$controller_
            scope = $rootScope.$new()

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaComponents"

        _setup()

    it "add attachment", () ->
        file = {
            name: 'name',
            size: 1000
        }

        mocks.attachmentsService.validate = sinon.stub()
        mocks.attachmentsService.validate.withArgs(file).returns(true)

        ctrl = $controller("AttachmentsSimple", {
            $scope: scope
        }, {
            attachments: Immutable.List()
        })

        ctrl.onAdd = sinon.spy()

        ctrl.addAttachment(file)

        expect(ctrl.attachments.size).to.be.equal(1)
        expect(ctrl.onAdd).to.have.been.calledOnce

    it "delete attachment", () ->
        attachments = Immutable.fromJS([
            {id: 1},
            {id: 2},
            {id: 3}
        ])

        ctrl = $controller("AttachmentsSimple", {
            $scope: scope
        }, {
            attachments: attachments
        })

        ctrl.onDelete = sinon.spy()


        attachment = attachments.get(1)

        ctrl.deleteAttachment(attachment)

        expect(ctrl.attachments.size).to.be.equal(2)
        expect(ctrl.onDelete.withArgs({attachment: attachment})).to.have.been.calledOnce
