###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "AttachmentController", ->
    $provide = null
    $controller = null
    scope = null
    mocks = {}

    _mockAttachmentsService = ->
        mocks.attachmentsService = {}

        $provide.value("tgAttachmentsService", mocks.attachmentsService)

    _mockTranslate = ->
        mocks.translate = {
            instant: sinon.stub()
        }

        $provide.value("$translate", mocks.translate)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockAttachmentsService()
            _mockTranslate()

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

    it "change edit mode", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            }
        })

        ctrl = $controller("Attachment", {
            $scope: scope
        }, {
            attachment : attachment
        })

        ctrl.onUpdate = sinon.spy()

        onUpdate = sinon.match (value) ->
            value = value.attachment.toJS()

            return value.editable

        , "onUpdate"

        ctrl.editMode(true)

        expect(ctrl.onUpdate).to.be.calledWith(onUpdate)

    it "delete", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            }
        })

        ctrl = $controller("Attachment", {
            $scope: scope
        }, {
            attachment : attachment
        })

        ctrl.onDelete = sinon.spy()

        onDelete = sinon.match (value) ->
            return value.attachment == attachment
        , "onDelete"

        ctrl.delete()

        expect(ctrl.onDelete).to.be.calledWith(onDelete)

    it "save", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            },
            loading: false,
            editable: false
        })

        ctrl = $controller("Attachment", {
            $scope: scope
        }, {
            attachment : attachment
        })

        ctrl.onUpdate = sinon.spy()

        onUpdateLoading = sinon.match (value) ->
            value = value.attachment.toJS()

            return value.loading
        , "onUpdateLoading"

        onUpdate = sinon.match (value) ->
            value = value.attachment.toJS()

            return (
                value.file.description == "ok" &&
                value.file.is_deprecated
            )
        , "onUpdate"

        ctrl.form = {
            description: "ok"
            is_deprecated: true
        }

        ctrl.save()

        attachment = ctrl.attachment.toJS()

        expect(ctrl.onUpdate).to.be.calledWith(onUpdateLoading)
        expect(ctrl.onUpdate).to.be.calledWith(onUpdate)
