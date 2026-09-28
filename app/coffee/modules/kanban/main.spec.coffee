describe "Kanban archived filters", ->
    $controller = null
    $compile = null
    $q = null
    $rootScope = null
    ctrl = null
    scope = null
    userstories = null
    location = null
    filters = null
    kanban = null
    kanbanResources = null

    beforeEach ->
        kanban = {
            reset: sinon.spy()
            archivedStatus: []
            statusHide: []
            showStatus: (id) -> _.remove(@statusHide, (hidden) -> hidden == id)
        }
        kanbanResources = {
            getStatusColumnModes: -> {7: true}
            storeStatusColumnModes: sinon.spy()
        }

        module "taigaKanban"
        module ($provide) ->
            $provide.value "$tgResources", {kanban: kanbanResources}
            $provide.value "tgProjectService", {project: Immutable.fromJS({id: 1})}
            $provide.value "tgKanbanUserstories", kanban
            return null

        inject (_$controller_, _$compile_, _$q_, _$rootScope_) ->
            $controller = _$controller_
            $compile = _$compile_
            $q = _$q_
            $rootScope = _$rootScope_

        scope = $rootScope.$new()
        scope.projectId = 1
        location = {
            search: sinon.stub().returns({tags: "keep"})
        }
        userstories = {
            listAll: sinon.stub().returns($q.defer().promise)
            filtersData: sinon.stub().returns($q.defer().promise)
        }
        filters = {
            getFilters: sinon.stub().returns($q.defer().promise)
        }

        ctrl = $controller "KanbanController", {
            $scope: scope
            $rootScope: $rootScope
            $tgRepo: {}
            $tgConfirm: {}
            $tgResources: {userstories: userstories}
            tgResources: {}
            $routeParams: {pslug: "project"}
            $q: $q
            $tgLocation: location
            tgAppMetaService: {}
            $tgNavUrls: {}
            $tgEvents: {}
            $tgAnalytics: {}
            $translate: {instant: -> "Kanban"}
            tgErrorHandlingService: {}
            $tgModel: {}
            tgKanbanUserstories: kanban
            $tgStorage: {set: sinon.spy()}
            tgFilterRemoteStorageService: filters
            tgProjectService: {}
            tgLightboxFactory: {}
            tgLoader: {}
            $timeout: sinon.stub()
        }

    it "excludes archived stories in list and filter counts", ->
        listParams = ctrl.loadUserstoriesParams()
        ctrl.generateFilters()

        expect(listParams.status__is_archived).to.equal(false)
        expect(userstories.filtersData.firstCall.args[0].status__is_archived).to.equal(false)

    it "omits the archived condition when an archived column is open", ->
        kanban.archivedStatus = [7]
        kanban.statusHide = [7]
        location.search.returns({tags: "keep", status__is_archived: "false", exclude_status: "7"})
        $rootScope.$broadcast("kanban:show-userstories-for-status", 7)
        listParams = ctrl.loadUserstoriesParams()

        expect(userstories.listAll.firstCall.args[1].status).to.equal(7)
        expect(userstories.listAll.firstCall.args[1]).not.to.have.property("status__is_archived")
        expect(userstories.listAll.firstCall.args[1]).not.to.have.property("exclude_status")
        expect(listParams).not.to.have.property("status__is_archived")
        expect(userstories.filtersData.firstCall.args[0]).not.to.have.property("status__is_archived")

    it "excludes archived columns that remain folded from list and counts", ->
        kanban.archivedStatus = [7, 8]
        kanban.statusHide = [8]
        listParams = ctrl.loadUserstoriesParams()
        ctrl.generateFilters()

        expect(listParams).not.to.have.property("status__is_archived")
        expect(listParams.exclude_status).to.equal("8")
        expect(userstories.filtersData.firstCall.args[0].exclude_status).to.equal("8")

        kanban.statusHide = []
        location.search.returns({tags: "keep", exclude_status: "8"})
        ctrl.generateFilters()
        expect(ctrl.loadUserstoriesParams()).not.to.have.property("exclude_status")
        expect(userstories.filtersData.secondCall.args[0]).not.to.have.property("exclude_status")

    it "opens an archived column through its fold action", ->
        kanban.archivedStatus = [7]
        kanban.statusHide = [7]
        kanban.hideStatus = (id) -> @statusHide.push(id)
        ctrl.initialLoad = true
        scope.ctrl = ctrl
        scope.usStatusList = [{id: 7, is_archived: true}]
        columnScope = scope.$new()
        $compile("<div tg-kanban-squish-column></div>")(columnScope)
        $rootScope.$digest()

        columnScope.foldStatus(scope.usStatusList[0])

        expect(kanban.statusHide).to.be.empty
        expect(kanbanResources.storeStatusColumnModes).to.have.been.calledWith(1, {7: false})
        expect(userstories.listAll.firstCall.args[1].status).to.equal(7)
        expect(userstories.filtersData.firstCall.args[0]).not.to.have.property("status__is_archived")

        ctrl.filtersReloadContent = sinon.spy()
        columnScope.foldStatus(scope.usStatusList[0])

        expect(kanban.statusHide).to.deep.equal([7])
        expect(ctrl.filtersReloadContent).to.have.been.calledOnce
        expect(userstories.filtersData.secondCall.args[0].status__is_archived).to.equal(false)

    it "restores the archived view from stored column modes", ->
        ctrl.rs.kanban = {getStatusColumnModes: -> {7: false, 8: true}}
        ctrl.projectService.project = {
            toJS: -> {
                id: 1
                is_kanban_activated: true
                points: []
                us_statuses: [{id: 7, is_archived: true}, {id: 8, is_archived: true}]
            }
        }
        kanban.addArchivedStatus = (id) -> @archivedStatus.push(id)
        kanban.hideStatus = (id) -> @statusHide.push(id)

        ctrl.loadProject()

        expect(ctrl.loadUserstoriesParams()).not.to.have.property("status__is_archived")
        expect(ctrl.loadUserstoriesParams().exclude_status).to.equal("8")
        expect(kanban.statusHide).to.deep.equal([8])

    it "removes a story moved into a hidden archived status after an event", ->
        kanban.userstoriesRaw = [{id: 12, status: 1}]
        kanban.getUsModel = sinon.stub().returns(kanban.userstoriesRaw[0])
        kanban.remove = sinon.spy()
        kanban.refresh = sinon.spy()
        userstories.listAll.returns($q.when([]))

        ctrl.eventsLoadUserstories({pk: 12})
        $rootScope.$digest()

        expect(userstories.listAll.firstCall.args[1].status__is_archived).to.equal(false)
        expect(kanban.remove).to.have.been.calledWith(kanban.userstoriesRaw[0])
        expect(userstories.filtersData.firstCall.args[0].status__is_archived).to.equal(false)

    it "refreshes counts after realtime creation and editing", ->
        kanban.userstoriesRaw = []
        kanban.add = sinon.spy()
        kanban.replaceModel = sinon.spy()
        kanban.refreshRawOrder = sinon.spy()
        kanban.refresh = sinon.spy()
        created = {id: 13, status: 1}
        userstories.listAll.returns($q.when([created]))

        ctrl.eventsLoadUserstories({pk: 13})
        $rootScope.$digest()

        expect(kanban.add).to.have.been.calledWith([created])
        expect(userstories.filtersData.firstCall.args[0].status__is_archived).to.equal(false)

        kanban.userstoriesRaw = [created]
        edited = {id: 13, status: 1, subject: "edited"}
        userstories.listAll.returns($q.when([edited]))
        ctrl.eventsLoadUserstories({pk: 13})
        $rootScope.$digest()

        expect(kanban.replaceModel).to.have.been.calledWith(edited)
        expect(userstories.filtersData.secondCall.args[0].status__is_archived).to.equal(false)

    it "keeps archived stories out of searches and later filter requests", ->
        ctrl.filterQ = "needle"
        expect(ctrl.loadUserstoriesParams()).to.include({q: "needle", status__is_archived: false})

        location.search.returns({assigned_users: "4", tags: "keep"})
        ctrl.generateFilters()
        expect(userstories.filtersData.firstCall.args[0]).to.include({
            assigned_users: "4"
            tags: "keep"
            status__is_archived: false
        })
