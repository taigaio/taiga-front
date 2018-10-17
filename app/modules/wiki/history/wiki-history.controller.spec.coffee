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
# File: wiki/history/wiki-history.controller.spec.coffee
###

describe "WikiHistorySection", ->
    provide = null
    controller = null
    mocks = {}

    _mockTgActivityService = () ->
        mocks.tgActivityService = {
            init: sinon.stub(),
            fetchEntries: sinon.stub()
        }

        provide.value "tgActivityService", mocks.tgActivityService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgActivityService()
            return null

    beforeEach ->
        module "taigaWikiHistory"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "initialize history entries with id", ->
        wikiId = 42

        historyCtrl = controller "WikiHistoryCtrl"
        historyCtrl.initializeHistory(wikiId)

        expect(mocks.tgActivityService.init).to.be.calledOnce
        expect(mocks.tgActivityService.init).to.be.calledWith('wiki', wikiId)
        expect(mocks.tgActivityService.fetchEntries).to.be.calledOnce

    it "initialize history entries without id",  ->
        historyCtrl = controller "WikiHistoryCtrl"
        historyCtrl.initializeHistory()

        expect(mocks.tgActivityService.init).to.not.be.calledOnce
        expect(mocks.tgActivityService.fetchEntries).to.be.calledOnce
