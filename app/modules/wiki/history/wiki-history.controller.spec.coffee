###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
