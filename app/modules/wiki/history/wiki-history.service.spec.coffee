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
# File: wiki/history/wiki-history.service.spec.coffee
###


describe "tgWikiHistoryService", ->
    $provide = null
    wikiHistoryService = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            wikiHistory: {
                getWikiHistory: sinon.stub()
            }
        }
        $provide.value("tgResources", mocks.tgResources)

    _mockXhrErrorService = () ->
        mocks.xhrErrorService = {
            response: sinon.stub()
        }

        $provide.value "tgXhrErrorService", mocks.xhrErrorService

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTgResources()
            _mockXhrErrorService()

            return null

    _inject = ->
        inject (_tgWikiHistoryService_) ->
            wikiHistoryService = _tgWikiHistoryService_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaWikiHistory"

        _setup()

    it "populate history entries", (done) ->
        wikiId = 42
        historyEntries = Immutable.List([
            {id: 1, name: 'history entrie 1'},
            {id: 2, name: 'history entrie 2'},
            {id: 3, name: 'history entrie 3'},
        ])

        mocks.tgResources.wikiHistory.getWikiHistory.withArgs(wikiId).promise().resolve(historyEntries)

        wikiHistoryService.setWikiId(wikiId)
        expect(wikiHistoryService.wikiId).to.be.equal(wikiId)

        expect(wikiHistoryService.historyEntries.size).to.be.equal(0)
        wikiHistoryService.loadHistoryEntries().then () ->
            expect(wikiHistoryService.historyEntries.size).to.be.equal(3)
            done()

    it "reset history entries if wikiId change", () ->
        wikiId = 42

        wikiHistoryService._historyEntries = Immutable.List([
            {id: 1, name: 'history entrie 1'},
            {id: 2, name: 'history entrie 2'},
            {id: 3, name: 'history entrie 3'},
        ])

        expect(wikiHistoryService.historyEntries.size).to.be.equal(3)
        wikiHistoryService.setWikiId(wikiId)
        expect(wikiHistoryService.historyEntries.size).to.be.equal(0)
