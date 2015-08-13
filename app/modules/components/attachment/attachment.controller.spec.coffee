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
# File: attchment.controller.spec.coffee
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

        ctrl.editable = false
        ctrl.editMode(true)

        expect(ctrl.attachment.get('editable')).to.be.true

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

        expect(ctrl.onUpdate).to.be.calledWith(onUpdate)
