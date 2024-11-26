###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "DiscoverSearch", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockTranslate = () ->
        mocks.translate = {}
        mocks.translate.instant = sinon.stub()

        $provide.value "$translate", mocks.translate

    _mockTgLocation = () ->
        mocks.mockTgLocation = {
            url: sinon.stub()
            search: sinon.stub()
        }

        $provide.value "$tgLocation", mocks.mockTgLocation

    _mockTgAnalytics = () ->
        mocks.tgAnalytics = {
            trackEvent: sinon.stub(),
            trackPage: sinon.stub()
        }

        $provide.value "$tgAnalytics", mocks.tgAnalytics

    _mockAppMetaService = () ->
        mocks.appMetaService = {
            setAll: sinon.spy()
        }

        $provide.value "tgAppMetaService", mocks.appMetaService

    _mockRouteParams = ->
        mocks.routeParams = {}

        $provide.value("$routeParams", mocks.routeParams)

    _mockRoute = ->
        mocks.route = {}

        $provide.value("$route", mocks.route)

    _mockDiscoverProjects = ->
        mocks.discoverProjects = {
            resetSearchList: sinon.spy(),
            fetchSearch: sinon.stub()
        }

        mocks.discoverProjects.fetchSearch.promise().resolve()

        $provide.value("tgDiscoverProjectsService", mocks.discoverProjects)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTranslate()
            _mockAppMetaService()
            _mockRoute()
            _mockRouteParams()
            _mockTgLocation()
            _mockTgAnalytics()
            _mockDiscoverProjects()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaDiscover"

        _setup()

    it "initialize meta data", () ->
        mocks.translate.instant
            .withArgs('DISCOVER.SEARCH.PAGE_TITLE')
            .returns('meta-title')
        mocks.translate.instant
            .withArgs('DISCOVER.SEARCH.PAGE_DESCRIPTION')
            .returns('meta-description')

        ctrl = $controller('DiscoverSearch')

        expect(mocks.appMetaService.setAll.calledWithExactly("meta-title", "meta-description")).to.be.true

    it "initialize search params", () ->
        mocks.routeParams.text = 'text'
        mocks.routeParams.filter = 'filter'
        mocks.routeParams.order_by = 'order'

        ctrl = $controller('DiscoverSearch')

        expect(ctrl.q).to.be.equal('text')
        expect(ctrl.filter).to.be.equal('filter')
        expect(ctrl.orderBy).to.be.equal('order')

    it "fetch", () ->
        ctrl = $controller('DiscoverSearch')

        ctrl.search = sinon.spy()

        ctrl.fetch()

        expect(mocks.discoverProjects.resetSearchList).to.have.been.called
        expect(ctrl.search).to.have.been.called
        expect(ctrl.page).to.be.equal(1)

    it "showMore", (done) ->
        ctrl = $controller('DiscoverSearch')

        ctrl.search = sinon.stub().promise()

        ctrl.showMore().then () ->
            expect(ctrl.loadingPagination).to.be.false

            done()

        expect(ctrl.loadingPagination).to.be.true
        expect(ctrl.search).to.have.been.called
        expect(ctrl.page).to.be.equal(2)

        ctrl.search.resolve()

    it "search", () ->
        mocks.discoverProjects.fetchSearch = sinon.stub()

        filter = {
            filter: '123'
        }

        ctrl = $controller('DiscoverSearch')

        ctrl.page = 1
        ctrl.q = 'text'
        ctrl.orderBy = 1

        ctrl.getFilter = () -> return filter

        params = {
            filter: '123',
            page: 1,
            q: 'text',
            order_by: 1
        }

        ctrl.search()

        expect(mocks.discoverProjects.fetchSearch).have.been.calledWith(sinon.match(params))

    it "get filter", () ->
        ctrl = $controller('DiscoverSearch')

        ctrl.filter = 'people'
        expect(ctrl.getFilter()).to.be.eql({is_looking_for_people: true})

        ctrl.filter = 'scrum'
        expect(ctrl.getFilter()).to.be.eql({is_backlog_activated: true})

        ctrl.filter = 'kanban'
        expect(ctrl.getFilter()).to.be.eql({is_kanban_activated: true})

    it "onChangeFilter", () ->
        ctrl = $controller('DiscoverSearch')

        mocks.route.updateParams = sinon.stub()

        ctrl.fetchByGlobalSearch = sinon.spy()

        ctrl.onChangeFilter('filter', 'query')

        expect(ctrl.filter).to.be.equal('filter')
        expect(ctrl.q).to.be.equal('query')
        expect(ctrl.fetchByGlobalSearch).to.have.been.called
        expect(mocks.route.updateParams).to.have.been.calledWith(sinon.match({filter: 'filter', text: 'query'}))

    it "onChangeOrder", () ->
        ctrl = $controller('DiscoverSearch')

        mocks.route.updateParams = sinon.stub()

        ctrl.fetchByOrderBy = sinon.spy()

        ctrl.onChangeOrder('order-by')

        expect(ctrl.orderBy).to.be.equal('order-by')
        expect(ctrl.fetchByOrderBy).to.have.been.called
        expect(mocks.route.updateParams).to.have.been.calledWith(sinon.match({order_by: 'order-by'}))

    it "fetchByGlobalSearch", (done) ->
        ctrl = $controller('DiscoverSearch')

        ctrl.fetch = sinon.stub().promise()

        ctrl.fetchByGlobalSearch().then () ->
            expect(ctrl.loadingGlobal).to.be.false

            done()

        expect(ctrl.loadingGlobal).to.be.true
        expect(ctrl.fetch).to.have.been.called

        ctrl.fetch.resolve()

    it "fetchByOrderBy", (done) ->
        ctrl = $controller('DiscoverSearch')

        ctrl.fetch = sinon.stub().promise()

        ctrl.fetchByOrderBy().then () ->
            expect(ctrl.loadingList).to.be.false

            done()

        expect(ctrl.loadingList).to.be.true
        expect(ctrl.fetch).to.have.been.called

        ctrl.fetch.resolve()
