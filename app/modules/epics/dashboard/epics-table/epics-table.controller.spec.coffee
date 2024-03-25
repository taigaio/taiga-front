###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "EpicTable", ->
    epicTableCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }
        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgEpicsService = () ->
        mocks.tgEpicsService = {
            createEpic: sinon.stub()
            nextPage: sinon.stub()
        }
        provide.value "tgEpicsService", mocks.tgEpicsService

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            project: Immutable.fromJS({
                'id': 3
            })
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mockTgStorageService = () ->
        mocks.tgStorage = {
            get: sinon.stub(),
            set: sinon.spy()
        }

        mocks.tgStorage.get.returns({col1: true})
        provide.value "$tgStorage", mocks.tgStorage

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgConfirm()
            _mockTgEpicsService()
            _mockTgStorageService()
            _mockTgProjectService()
            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "toggle table options", () ->
        epicTableCtrl = controller "EpicsTableCtrl"
        epicTableCtrl.displayOptions = true
        epicTableCtrl.toggleEpicTableOptions()
        expect(epicTableCtrl.displayOptions).to.be.false

    it "next page", () ->
        epicTableCtrl = controller "EpicsTableCtrl"

        epicTableCtrl.nextPage()

        expect(mocks.tgEpicsService.nextPage).to.have.been.calledOnce

    it "storage view options", () ->
        epicTableCtrl = controller "EpicsTableCtrl"

        expect(epicTableCtrl.options).to.be.eql({col1: true})
