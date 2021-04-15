###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
