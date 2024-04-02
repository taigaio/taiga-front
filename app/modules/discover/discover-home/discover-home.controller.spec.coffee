###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "DiscoverHomeController", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockTranslate = () ->
        mocks.translate = {}
        mocks.translate.instant = sinon.stub()

        $provide.value "$translate", mocks.translate

    _mockAppMetaService = () ->
        mocks.appMetaService = {
            setAll: sinon.spy()
        }

        $provide.value "tgAppMetaService", mocks.appMetaService

    _mockLocation = ->
        mocks.location = {}

        $provide.value('$tgLocation', mocks.location)

    _mockNavUrls = ->
        mocks.navUrls = {}

        $provide.value('$tgNavUrls', mocks.navUrls)

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTranslate()
            _mockAppMetaService()
            _mockLocation()
            _mockNavUrls()

            return null

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaDiscover"

        _mocks()
        _setup()

    it "initialize meta data", () ->
        mocks.translate.instant
            .withArgs('DISCOVER.PAGE_TITLE')
            .returns('meta-title')
        mocks.translate.instant
            .withArgs('DISCOVER.PAGE_DESCRIPTION')
            .returns('meta-description')

        ctrl = $controller('DiscoverHome')

        expect(mocks.appMetaService.setAll.calledWithExactly("meta-title", "meta-description")).to.be.true

    it "onSubmit redirect to discover search", () ->
        mocks.navUrls.resolve = sinon.stub().withArgs('discover-search').returns('url')

        pathSpy = sinon.spy()
        searchStub = {
            path: pathSpy
        }

        mocks.location.search = sinon.stub().withArgs('text', 'query').returns(searchStub)

        ctrl = $controller("DiscoverHome")

        ctrl.onSubmit('query')

        expect(pathSpy).to.have.been.calledWith('url')
