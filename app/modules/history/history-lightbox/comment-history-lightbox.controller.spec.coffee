###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "LightboxDisplayHistoricController", ->
    provide = null
    controller = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            history: {
                getCommentHistory: sinon.stub()
            }
        }

        provide.value "$tgResources", mocks.tgResources

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgResources()
            return null

    beforeEach ->
        module "taigaHistory"
        _mocks()

        inject ($controller) ->
            controller = $controller

    it "load historic", (done) ->
        historicLbCtrl = controller "LightboxDisplayHistoricCtrl"

        historicLbCtrl.name = "type"
        historicLbCtrl.object = 1
        historicLbCtrl.comment = {}
        historicLbCtrl.comment.id = 1

        type = historicLbCtrl.name
        objectId = historicLbCtrl.object
        activityId = historicLbCtrl.comment.id

        promise = mocks.tgResources.history.getCommentHistory.withArgs(type, objectId, activityId).promise().resolve()

        historicLbCtrl._loadHistoric().then (data) ->
            expect(historicLbCtrl.commentHistoryEntries).is.equal(data)
            done()
