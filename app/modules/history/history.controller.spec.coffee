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
# File: subscriptions.controller.spec.coffee
###

describe "HistorySection", ->
    provide = null
    controller = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            history: {
                get: sinon.stub()
                deleteComment: sinon.stub()
                undeleteComment: sinon.stub()
                editComment: sinon.stub()
            }
        }

        provide.value "$tgResources", mocks.tgResources

    _mockTgRepo = () ->
        mocks.tgRepo = {
            save: sinon.stub()
        }

        provide.value "$tgRepo", mocks.tgRepo

    _mocktgStorage = () ->
        mocks.tgStorage = {
            get: sinon.stub()
            set: sinon.stub()
        }
        provide.value "$tgStorage", mocks.tgStorage

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgResources()
            _mockTgRepo()
            _mocktgStorage()
            return null

    beforeEach ->
        module "taigaHistory"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it.only "load historic", (done) ->
        promise = mocks.tgResources.history.get.promise().resolve()
        historyCtrl = controller "HistorySection"

        historyCtrl._getComments = sinon.stub()
        historyCtrl._getActivities = sinon.stub()

        name = "name"
        id = 4

        promise = mocks.tgResources.history.get.withArgs(name, id).promise().resolve()
        historyCtrl._loadHistory().then (data) ->
            expect(historyCtrl._getComments).have.been.calledWith(data)
            expect(historyCtrl._getActivities).have.been.calledWith(data)
            done()
