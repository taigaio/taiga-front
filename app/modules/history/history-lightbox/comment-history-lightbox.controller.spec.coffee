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
# File: history/history-lightbox/comment-history-lightbox.controller.spec.coffee
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
