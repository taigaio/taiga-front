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

    _mockTgWikiHistoryService = () ->
        mocks.tgWikiHistoryService = {
            setWikiId: sinon.stub(),
            loadHistoryEntries: sinon.stub()
        }

        provide.value "tgWikiHistoryService", mocks.tgWikiHistoryService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgWikiHistoryService()
            return null

    beforeEach ->
        module "taigaWikiHistory"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "initialize histori entries with id", ->
        wikiId = 42

        historyCtrl = controller "WikiHistoryCtrl"
        historyCtrl.initializeHistoryEntries(wikiId)

        expect(mocks.tgWikiHistoryService.setWikiId).to.be.calledOnce
        expect(mocks.tgWikiHistoryService.setWikiId).to.be.calledWith(wikiId)
        expect(mocks.tgWikiHistoryService.loadHistoryEntries).to.be.calledOnce

    it "initialize history entries without id",  ->
        historyCtrl = controller "WikiHistoryCtrl"
        historyCtrl.initializeHistoryEntries()

        expect(mocks.tgWikiHistoryService.setWikiId).to.not.be.calledOnce
        expect(mocks.tgWikiHistoryService.loadHistoryEntries).to.be.calledOnce
