###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "EpicsDashboard", ->
    provide = null
    controller = null
    $q = $rootScope = null
    mocks = {}

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }
        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            setProjectBySlug: sinon.stub()
            hasPermission: sinon.stub()
            isEpicsDashboardEnabled: sinon.stub()
            project: Immutable.Map({
                "name": "testing name"
                "description": "testing description"
            })
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mockTgEpicsService = () ->
        mocks.tgEpicsService = {
            clear: sinon.stub()
            fetchEpics: sinon.stub()
        }
        provide.value "tgEpicsService", mocks.tgEpicsService

    _mockTgResources = () ->
        mocks.tgResources = {
            epics: {
                filtersData: sinon.stub()
            }
        }
        provide.value "tgResources", mocks.tgResources

    _mockTgLocation = () ->
        mocks.urlParams = {
            page: "4"
            q: "authentication"
            assigned_to: "7"
            exclude_status: "2"
        }
        mocks.tgLocation = {
            search: (name, value) ->
                if _.isObject(name)
                    mocks.urlParams = name
                    return mocks.urlParams
                if name?
                    if value is null
                        delete mocks.urlParams[name]
                    else
                        mocks.urlParams[name] = value
                return mocks.urlParams
            isInCurrentRouteParams: sinon.stub().returns(false)
        }
        mocks.tgLocation.noreload = sinon.stub().returns(mocks.tgLocation)
        mocks.tgLocation.replace = sinon.stub()
        provide.value "$tgLocation", mocks.tgLocation

    _mockTgStorage = () ->
        mocks.tgStorage = {
            get: sinon.stub().returns({})
            set: sinon.stub()
        }
        provide.value "$tgStorage", mocks.tgStorage

    _mockFilterRemoteStorageService = () ->
        mocks.filterRemoteStorageService = {
            getFilters: sinon.stub()
            storeFilters: sinon.stub()
        }
        provide.value "tgFilterRemoteStorageService", mocks.filterRemoteStorageService

    _mockRouteParams = () ->
        mocks.routeParams = {
            pslug: sinon.stub()
        }

        provide.value "$routeParams", mocks.routeParams

    _mockTgErrorHandlingService = () ->
        mocks.tgErrorHandlingService = {
            permissionDenied: sinon.stub()
            notFound: sinon.stub()
        }

        provide.value "tgErrorHandlingService", mocks.tgErrorHandlingService

    _mockTgLightboxFactory = () ->
        mocks.tgLightboxFactory = {
            create: sinon.stub()
        }

        provide.value "tgLightboxFactory", mocks.tgLightboxFactory

    _mockLightboxService = () ->
        mocks.lightboxService = {
            closeAll: sinon.stub()
        }

        provide.value "lightboxService", mocks.lightboxService

    _mockTgAppMetaService = () ->
        mocks.tgAppMetaService = {
            setfn: sinon.stub()
        }

        provide.value "tgAppMetaService", mocks.tgAppMetaService

    _mockTranslate = () ->
        mocks.translate = {instant: sinon.stub().returns("Filter")}

        provide.value "$translate", mocks.translate

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgConfirm()
            _mockTgProjectService()
            _mockTgEpicsService()
            _mockTgResources()
            _mockTgLocation()
            _mockTgStorage()
            _mockFilterRemoteStorageService()
            _mockRouteParams()
            _mockTgErrorHandlingService()
            _mockTgLightboxFactory()
            _mockLightboxService()
            _mockTgAppMetaService()
            _mockTranslate()

            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller, _$q_, _$rootScope_) ->
            controller = $controller
            $q = _$q_
            $rootScope = _$rootScope_

    createController = () ->
        mocks.filterRemoteStorageService.getFilters.returns($q.when({}))
        mocks.filterRemoteStorageService.storeFilters.returns($q.when())
        return controller("EpicsDashboardCtrl", {$scope: $rootScope.$new()})

    it "metada is set", () ->
        ctrl = createController()
        expect(mocks.tgAppMetaService.setfn).have.been.called

    it "load data because epics panel is enabled and user has permissions", ->
        ctrl = createController()

        mocks.tgProjectService.setProjectBySlug.returns($q.when("ok"))
        mocks.tgProjectService.hasPermission
            .returns(true)
        mocks.tgProjectService.isEpicsDashboardEnabled
            .returns(true)
        mocks.tgResources.epics.filtersData.returns($q.when({statuses: []}))
        mocks.tgEpicsService.fetchEpics.returns($q.when())

        ctrl.loadInitialData()
        $rootScope.$apply()
        $rootScope.$apply()

        expect(mocks.tgErrorHandlingService.permissionDenied).not.have.been.called
        expect(mocks.tgErrorHandlingService.notFound).not.have.been.called
        expect(mocks.tgEpicsService.fetchEpics).have.been.called

    it "loads facet counts and epics with the active URL filters", ->
        ctrl = createController()
        project = Immutable.Map({id: 42})
        mocks.tgProjectService.project = project
        mocks.tgProjectService.setProjectBySlug.returns($q.when("ok"))
        mocks.tgProjectService.hasPermission.returns(true)
        mocks.tgProjectService.isEpicsDashboardEnabled.returns(true)
        mocks.tgEpicsService.fetchEpics.returns($q.when())
        mocks.tgResources.epics.filtersData.returns($q.when({statuses: []}))

        ctrl.loadInitialData()
        $rootScope.$apply()
        $rootScope.$apply()

        expect(mocks.tgResources.epics.filtersData).to.have.been.calledWith({
            project: 42
            q: "authentication"
            assigned_to: "7"
            exclude_status: "2"
        })
        expect(mocks.tgEpicsService.fetchEpics).to.have.been.calledWith(false, {
            project: 42
            page: "4"
            q: "authentication"
            assigned_to: "7"
            exclude_status: "2"
        })

    it "resets pagination before reloading changed filters", ->
        ctrl = createController()
        project = Immutable.Map({id: 42})
        mocks.tgProjectService.project = project
        params = {page: "4", status: "3"}
        mocks.tgLocation.search = (name, value) ->
            if name is undefined
                return params
            if value is null
                delete params[name]
            else
                params[name] = value
            return mocks.tgLocation
        mocks.tgLocation.noreload = sinon.stub().returns(mocks.tgLocation)
        mocks.tgResources.epics.filtersData.returns($q.when({statuses: []}))
        mocks.tgEpicsService.fetchEpics.returns($q.when())

        ctrl.reloadWithFilters()
        $rootScope.$apply()
        $rootScope.$apply()

        expect(params).not.to.have.property("page")
        expect(mocks.tgEpicsService.clear).to.have.been.calledBefore(mocks.tgResources.epics.filtersData)
        expect(mocks.tgResources.epics.filtersData).to.have.been.calledWith({project: 42, status: "3"})
        expect(mocks.tgEpicsService.fetchEpics).to.have.been.calledWith(false, {project: 42, status: "3"})

    it "sends the same combined filters to facets and the epic list", ->
        ctrl = createController()
        mocks.tgProjectService.project = Immutable.Map({id: 42})
        mocks.urlParams = {assigned_to: "7", exclude_status: "2"}
        mocks.tgResources.epics.filtersData.returns($q.when({statuses: []}))
        mocks.tgEpicsService.fetchEpics.returns($q.when())

        ctrl.reloadWithFilters()
        $rootScope.$apply()
        $rootScope.$apply()
        mocks.urlParams.exclude_tags = "Legacy"
        ctrl.reloadWithFilters()
        $rootScope.$apply()
        $rootScope.$apply()

        facetsParams = mocks.tgResources.epics.filtersData.secondCall.args[0]
        listParams = mocks.tgEpicsService.fetchEpics.secondCall.args[1]
        expect(facetsParams).to.deep.equal({
            project: 42
            assigned_to: "7"
            exclude_status: "2"
            exclude_tags: "Legacy"
        })
        expect(_.omit(listParams, "page")).to.deep.equal(facetsParams)

    it "maps epic facets into the shared filter categories", ->
        ctrl = createController()
        ctrl.setFiltersFromData({
            statuses: [{id: 2, name: "Closed", color: "#aaa", count: 3}]
            assigned_to: [{id: 7, full_name: "Alex User", count: 2}, {id: null, count: 1}]
            owners: [{id: 8, full_name: "Taylor Owner", count: 4}]
            tags: [{name: "Legacy", count: 1}]
        })

        expect(_.map(ctrl.filters, "dataType")).to.deep.equal(["status", "assigned_to", "owner", "tags"])
        expect(ctrl.filters[0].content[0]).to.include({id: "2", name: "Closed"})
        expect(ctrl.filters[1].content[0]).to.include({id: "7", name: "Alex User"})
        expect(ctrl.filters[1].content[1]).to.include({id: "null", name: "Unassigned"})
        expect(ctrl.filters[2].content[0]).to.include({id: "8", name: "Taylor Owner"})
        expect(ctrl.filters[3].content[0]).to.include({id: "Legacy", name: "Legacy"})
        expect(_.map(ctrl.selectedFilters, (filter) -> [filter.dataType, filter.id, filter.mode])).to.deep.equal([
            ["status", "2", "exclude"]
            ["assigned_to", "7", "include"]
        ])

    it "supports include, exclude, search, remove, and clearing filters", ->
        ctrl = createController()
        ctrl.reloadWithFilters = sinon.spy()

        ctrl.addFilter({category: {dataType: "status"}, filter: {id: "2"}, mode: "exclude"})
        ctrl.addFilter({category: {dataType: "tags"}, filter: {id: "Legacy"}, mode: "exclude"})
        ctrl.changeQ("authentication")

        expect(mocks.urlParams.exclude_status).to.equal("2")
        expect(mocks.urlParams.exclude_tags).to.equal("Legacy")
        expect(mocks.urlParams.q).to.equal("authentication")

        ctrl.removeFilter({dataType: "status", id: "2", mode: "exclude"})
        expect(mocks.urlParams).not.to.have.property("exclude_status")

        ctrl.clearFilters()
        expect(mocks.urlParams).to.deep.equal({})
        expect(ctrl.reloadWithFilters.callCount).to.equal(5)

    it "restores stored filters only when the URL has no filters", ->
        mocks.urlParams = {}
        mocks.routeParams.pslug = "project"
        mocks.tgStorage.get.returns({status: "3", exclude_tags: "Legacy", q: "not-restored"})

        ctrl = createController()

        expect(mocks.urlParams).to.deep.equal({status: "3", exclude_tags: "Legacy"})
        expect(mocks.tgLocation.replace).to.have.been.calledOnce
        expect(ctrl.filterQ).to.equal(undefined)

    it "keeps URL filters ahead of stored filters", ->
        mocks.routeParams.pslug = "project"
        mocks.tgStorage.get.returns({status: "3"})

        createController()

        expect(mocks.urlParams).to.deep.equal({
            page: "4"
            q: "authentication"
            assigned_to: "7"
            exclude_status: "2"
        })
        expect(mocks.tgLocation.replace).not.to.have.been.called

    it "persists filter changes by project", ->
        mocks.routeParams.pslug = "project"
        mocks.urlParams = {exclude_tags: "Legacy"}
        ctrl = createController()
        ctrl.reloadWithFilters = sinon.spy()

        ctrl.addFilter({category: {dataType: "status"}, filter: {id: "3"}, mode: "include"})

        expect(mocks.tgStorage.set).to.have.been.calledOnce
        expect(mocks.tgStorage.set.firstCall.args[1]).to.deep.equal({status: "3", exclude_tags: "Legacy"})

    it "saves combined filters through remote storage", ->
        mocks.routeParams.pslug = "project"
        mocks.tgProjectService.project = Immutable.Map({id: 42})
        mocks.urlParams = {assigned_to: "7", exclude_status: "2", exclude_tags: "Legacy", q: "authentication"}
        ctrl = createController()

        ctrl.saveCustomFilter("Mine")
        $rootScope.$apply()
        $rootScope.$apply()

        expect(mocks.filterRemoteStorageService.getFilters).to.have.been.calledWith(42, "epics-custom-filters")
        expect(mocks.filterRemoteStorageService.storeFilters).to.have.been.calledWith(42, {
            Mine: {assigned_to: "7", exclude_status: "2", exclude_tags: "Legacy"}
        }, "epics-custom-filters")

    it "loads and applies a saved include/exclude filter", ->
        mocks.tgProjectService.project = Immutable.Map({id: 42})
        mocks.urlParams = {}
        savedFilters = {Mine: {assigned_to: "7", exclude_status: "2", exclude_tags: "Legacy"}}
        ctrl = createController()
        mocks.filterRemoteStorageService.getFilters.returns($q.when(savedFilters))
        ctrl.reloadWithFilters = sinon.spy()
        mocks.tgResources.epics.filtersData.returns($q.when({statuses: [], assigned_to: [], owners: [], tags: []}))

        ctrl.loadFilterData({project: 42}).then () ->
            customFilter = ctrl.customFilters[0]
            ctrl.selectCustomFilter(customFilter)
        $rootScope.$apply()
        $rootScope.$apply()

        expect(ctrl.customFilters).to.deep.equal([{id: "Mine", name: "Mine", filter: savedFilters.Mine}])
        expect(mocks.urlParams).to.deep.equal(savedFilters.Mine)
        expect(ctrl.reloadWithFilters).to.have.been.calledOnce

    it "deletes a saved filter through remote storage", ->
        mocks.tgProjectService.project = Immutable.Map({id: 42})
        savedFilters = {Mine: {assigned_to: "7", exclude_status: "2", exclude_tags: "Legacy"}}
        mocks.filterRemoteStorageService.getFilters.returns($q.when(savedFilters))
        mocks.filterRemoteStorageService.storeFilters.returns($q.when())
        ctrl = createController()
        ctrl.customFilters = [{id: "Mine", name: "Mine", filter: savedFilters.Mine}]

        ctrl.removeCustomFilter(ctrl.customFilters[0])
        $rootScope.$apply()
        $rootScope.$apply()

        expect(mocks.filterRemoteStorageService.storeFilters).to.have.been.calledWith(42, {}, "epics-custom-filters")
        expect(ctrl.customFilters).to.deep.equal([])

    it "not load data because epics panel is not enabled", (done) ->
        ctrl = createController()

        mocks.tgProjectService.setProjectBySlug
            .promise()
            .resolve("ok")
        mocks.tgProjectService.hasPermission
            .returns(true)
        mocks.tgProjectService.isEpicsDashboardEnabled
            .returns(false)

        ctrl.loadInitialData().then () ->
            expect(mocks.tgErrorHandlingService.permissionDenied).not.have.been.called
            expect(mocks.tgErrorHandlingService.notFound).have.been.called
            expect(mocks.tgEpicsService.fetchEpics).not.have.been.called
            done()

    it "not load data because user has not permissions", (done) ->
        ctrl = createController()

        mocks.tgProjectService.setProjectBySlug
            .promise()
            .resolve("ok")
        mocks.tgProjectService.hasPermission
            .returns(false)
        mocks.tgProjectService.isEpicsDashboardEnabled
            .returns(true)

        ctrl.loadInitialData().then () ->
            expect(mocks.tgErrorHandlingService.permissionDenied).have.been.called
            expect(mocks.tgErrorHandlingService.notFound).not.have.been.called
            expect(mocks.tgEpicsService.fetchEpics).not.have.been.called
            done()

    it "not load data because epics panel is not enabled and user has not permissions", (done) ->
        ctrl = createController()

        mocks.tgProjectService.setProjectBySlug
            .promise()
            .resolve("ok")
        mocks.tgProjectService.hasPermission
            .returns(false)
        mocks.tgProjectService.isEpicsDashboardEnabled
            .returns(false)

        ctrl.loadInitialData().then () ->
            expect(mocks.tgErrorHandlingService.permissionDenied).not.have.been.called
            expect(mocks.tgErrorHandlingService.notFound).have.been.called
            expect(mocks.tgEpicsService.fetchEpics).not.have.been.called
            done()
