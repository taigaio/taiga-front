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
# File: components/detail/header/detail-header.controller.spec.coffee
###

describe "DetailHeaderComponent", ->
    DetailHeaderCtrl =  null
    provide = null
    controller = null
    rootScope = null
    mocks = {}

    _mockRootScope = () ->
        mocks.rootScope = {
            $broadcast: sinon.stub()
        }

        provide.value "$rootScope", mocks.rootScope

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgQueueModelTransformation = () ->
        mocks.modelTransform = {
            save: sinon.stub()
        }

        provide.value "$tgQueueModelTransformation", mocks.tgQueueModelTransformation

    _mockWindow = () ->
        mocks.window = {
            getSelection: sinon.stub()
        }

        provide.value "$window", mocks.window

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockRootScope()
            _mockTgConfirm()
            _mockTgQueueModelTransformation()
            _mockWindow()

            return null

    beforeEach ->
        module "taigaBase"

        _mocks()

        inject ($controller) ->
            controller = $controller

            DetailHeaderCtrl = controller "DetailHeaderCtrl", {}, {
                item: {
                    subject: 'Example subject'
                }
            }

        DetailHeaderCtrl.originalSubject = DetailHeaderCtrl.item.subject

    it "check permissions", () ->
        DetailHeaderCtrl.project = {
            my_permissions: ['view_us']
        }
        DetailHeaderCtrl.requiredPerm = 'view_us'
        DetailHeaderCtrl._checkPermissions()
        expect(DetailHeaderCtrl.permissions).to.be.eql({canEdit: true})

    it "edit subject without selection", () ->
        mocks.window.getSelection.returns({
            type: 'Range'
        })
        DetailHeaderCtrl.editSubject(true)
        expect(DetailHeaderCtrl.editMode).to.be.false

    it "edit subject on click", () ->
        mocks.window.getSelection.returns({
            type: 'potato'
        })
        DetailHeaderCtrl.editSubject(true)
        expect(DetailHeaderCtrl.editMode).to.be.true

    it "do not edit subject", () ->
        mocks.window.getSelection.returns({
            type: 'Range'
        })
        DetailHeaderCtrl.editSubject(false)
        expect(DetailHeaderCtrl.editMode).to.be.false

    it "save on keydown Enter", () ->
        event = {}
        event.which = 13
        DetailHeaderCtrl.saveSubject = sinon.stub()
        DetailHeaderCtrl.onKeyDown(event)
        expect(DetailHeaderCtrl.saveSubject).have.been.called

    it "don't save on keydown ESC", () ->
        event = {}
        event.which = 27
        DetailHeaderCtrl.editSubject = sinon.stub()
        DetailHeaderCtrl.onKeyDown(event)
        expect(DetailHeaderCtrl.item.subject).to.be.equal(DetailHeaderCtrl.originalSubject)
        expect(DetailHeaderCtrl.editSubject).have.been.calledWith(false)
