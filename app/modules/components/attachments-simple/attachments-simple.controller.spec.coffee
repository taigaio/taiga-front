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
# File: components/attachments-simple/attachments-simple.controller.spec.coffee
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
