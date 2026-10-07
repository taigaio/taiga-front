###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgEpicsService", ->
    epicsService = provide = $q = $rootScope = null
    mocks = {}

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            project: Immutable.Map({
                "id": 1
            })
        }

        provide.value "tgProjectService", mocks.tgProjectService

    _mockTgAttachmentsService = () ->
        mocks.tgAttachmentsService = {
            upload: sinon.stub()
        }

        provide.value "tgAttachmentsService", mocks.tgAttachmentsService

    _mockTgResources = () ->
        mocks.tgResources = {
            epics: {
                list: sinon.stub()
                post: sinon.stub()
                patch: sinon.stub()
                reorder: sinon.stub()
                reorderRelatedUserstory: sinon.stub()
            }
            userstories: {
                listInEpic: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResources

    _mockTgXhrErrorService = () ->
        mocks.tgXhrErrorService = {
            response: sinon.stub()
        }

        provide.value "tgXhrErrorService", mocks.tgXhrErrorService

    _inject = (callback) ->
        inject (_tgEpicsService_, _$q_, _$rootScope_) ->
            epicsService = _tgEpicsService_
            $q = _$q_
            $rootScope = _$rootScope_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgProjectService()
            _mockTgAttachmentsService()
            _mockTgResources()
            _mockTgXhrErrorService()
            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaEpics"
        _setup()
        _inject()

    it "clear epics", () ->
        epicsService._epics = Immutable.List(Immutable.Map({
            'id': 1
        }))

        epicsService.clear()
        expect(epicsService._epics.size).to.be.equal(0)

    it "fetch epics success", () ->
        result = {}
        result.list = Immutable.fromJS([
            { id: 111 }
            { id: 112 }
        ])

        result.headers = () -> true

        promise = mocks.tgResources.epics.list.withArgs(1, {page: 1}).promise()

        fetchPromise = epicsService.fetchEpics()

        expect(epicsService._loadingEpics).to.be.true
        expect(epicsService._disablePagination).to.be.true

        promise.resolve(result)

        fetchPromise.then () ->
            expect(epicsService.epics).to.be.equal(result.list)
            expect(epicsService._loadingEpics).to.be.false
            expect(epicsService._disablePagination).to.be.false

    it "fetch epics success, last page", () ->
        result = {}
        result.list = Immutable.fromJS([
            { id: 111 }
            { id: 112 }
        ])

        result.headers = () -> false

        promise = mocks.tgResources.epics.list.withArgs(1, {page: 1}).promise()

        fetchPromise = epicsService.fetchEpics()

        expect(epicsService._loadingEpics).to.be.true
        expect(epicsService._disablePagination).to.be.true

        promise.resolve(result)

        fetchPromise.then () ->
            expect(epicsService.epics).to.be.equal(result.list)
            expect(epicsService._loadingEpics).to.be.false
            expect(epicsService._disablePagination).to.be.true

    it "keeps active filters when fetching subsequent pages", () ->
        result = {
            list: Immutable.List()
            headers: () -> true
        }
        mocks.tgResources.epics.list.returns($q.when(result))

        epicsService.fetchEpics(false, {q: "authentication", exclude_status: "2"})
        epicsService.nextPage()

        expect(mocks.tgResources.epics.list.firstCall.args).to.deep.equal([
            1
            {q: "authentication", exclude_status: "2", page: 1}
        ])
        expect(mocks.tgResources.epics.list.secondCall.args).to.deep.equal([
            1
            {q: "authentication", exclude_status: "2", page: 2}
        ])

    it "starts filtered results from the first page after clearing", () ->
        mocks.tgResources.epics.list.returns($q.when({
            list: Immutable.List()
            headers: () -> true
        }))

        epicsService.fetchEpics(false, {q: "authentication"})
        epicsService.nextPage()
        epicsService.clear()
        epicsService.fetchEpics(false, {status: "3"})

        expect(mocks.tgResources.epics.list.lastCall.args).to.deep.equal([
            1
            {status: "3", page: 1}
        ])

    it "keeps active filters after a reset fetch", () ->
        mocks.tgResources.epics.list.returns($q.when({
            list: Immutable.List()
            headers: () -> true
        }))

        epicsService.fetchEpics(false, {status: "3", exclude_tags: "Legacy"})
        epicsService.fetchEpics(true)
        $rootScope.$apply()
        $rootScope.$apply()
        epicsService.nextPage()

        expect(mocks.tgResources.epics.list.lastCall.args).to.deep.equal([
            1
            {status: "3", exclude_tags: "Legacy", page: 2}
        ])

    it "keeps the list while resetting and paginates the replacement results", ->
        previous = Immutable.fromJS([{id: 1}])
        replacement = Immutable.fromJS([{id: 2}])
        epicsService._epics = previous
        epicsService._page = 4
        pending = $q.defer()
        mocks.tgResources.epics.list.onFirstCall().returns(pending.promise)
        mocks.tgResources.epics.list.onSecondCall().returns($q.when({
            list: Immutable.fromJS([{id: 3}])
            headers: () -> false
        }))

        epicsService.fetchEpics(true, {q: "new", exclude_status: "2"})

        expect(epicsService.epics).to.equal(previous)
        expect(epicsService._loadingEpics).to.be.true
        expect(epicsService._disablePagination).to.be.true
        expect(mocks.tgResources.epics.list.firstCall.args[1]).to.deep.equal({
            q: "new", exclude_status: "2", page: 1
        })

        pending.resolve({list: replacement, headers: () -> true})
        $rootScope.$apply()
        expect(epicsService.epics).to.equal(replacement)
        expect(epicsService._loadingEpics).to.be.false
        epicsService.nextPage()
        $rootScope.$apply()

        expect(mocks.tgResources.epics.list.secondCall.args[1]).to.deep.equal({
            q: "new", exclude_status: "2", page: 2
        })
        expect(epicsService.epics.toJS()).to.deep.equal([{id: 2}, {id: 3}])

    it "only clears a search with no matches once its response arrives", ->
        epicsService._epics = Immutable.fromJS([{id: 1}])
        pending = $q.defer()
        mocks.tgResources.epics.list.returns(pending.promise)

        epicsService.fetchEpics(true, {q: "no matches"})
        expect(epicsService.epics.size).to.equal(1)
        pending.resolve({list: Immutable.List(), headers: () -> false})
        $rootScope.$apply()

        expect(epicsService.epics.size).to.equal(0)
        expect(epicsService._loadingEpics).to.be.false
        expect(epicsService._disablePagination).to.be.true

    it "ignores older searches and pagination responses after a reset", ->
        previous = Immutable.fromJS([{id: 1}])
        epicsService._epics = previous
        oldPage = $q.defer()
        olderSearch = $q.defer()
        latestSearch = $q.defer()
        mocks.tgResources.epics.list.onFirstCall().returns(oldPage.promise)
        mocks.tgResources.epics.list.onSecondCall().returns(olderSearch.promise)
        mocks.tgResources.epics.list.onThirdCall().returns(latestSearch.promise)

        epicsService.nextPage()
        epicsService.fetchEpics(true, {q: "a"})
        epicsService.fetchEpics(true, {q: "ab"})
        olderSearch.resolve({list: Immutable.fromJS([{id: 2}]), headers: () -> true})
        $rootScope.$apply()
        expect(epicsService.epics).to.equal(previous)
        expect(epicsService._loadingEpics).to.be.true
        expect(epicsService._disablePagination).to.be.true

        latestSearch.resolve({list: Immutable.fromJS([{id: 3}]), headers: () -> false})
        $rootScope.$apply()
        oldPage.resolve({list: Immutable.fromJS([{id: 4}]), headers: () -> true})
        $rootScope.$apply()

        expect(epicsService.epics.toJS()).to.deep.equal([{id: 3}])
        expect(epicsService._loadingEpics).to.be.false
        expect(epicsService._disablePagination).to.be.true

    it "ignores responses after the service is cleared", ->
        pending = $q.defer()
        mocks.tgResources.epics.list.returns(pending.promise)
        epicsService.fetchEpics()
        epicsService.clear()
        pending.resolve({list: Immutable.fromJS([{id: 1}]), headers: () -> true})
        $rootScope.$apply()

        expect(epicsService.epics.size).to.equal(0)
        expect(epicsService._loadingEpics).to.be.false

    it "ignores outdated errors and preserves results when the latest search fails", ->
        previous = Immutable.fromJS([{id: 1}])
        epicsService._epics = previous
        older = $q.defer()
        latest = $q.defer()
        mocks.tgResources.epics.list.onFirstCall().returns(older.promise)
        mocks.tgResources.epics.list.onSecondCall().returns(latest.promise)
        epicsService.fetchEpics(true, {q: "a"})
        epicsService.fetchEpics(true, {q: "ab"})
        older.reject({status: 500})
        $rootScope.$apply()

        expect(mocks.tgXhrErrorService.response).not.to.have.been.called
        expect(epicsService._loadingEpics).to.be.true
        latest.reject({status: 503})
        $rootScope.$apply()

        expect(mocks.tgXhrErrorService.response).to.have.been.calledOnce
        expect(mocks.tgXhrErrorService.response).to.have.been.calledWith({status: 503})
        expect(epicsService.epics).to.equal(previous)
        expect(epicsService._loadingEpics).to.be.false

    it "fetch epics error", () ->
        epics = Immutable.fromJS([
            { id: 111 }
            { id: 112 }
        ])
        promise = mocks.tgResources.epics.list.withArgs(1, {page: 1}).promise().reject(new Error("error"))
        epicsService.fetchEpics().then () ->
            expect(mocks.tgXhrErrorService.response.withArgs(new Error("error"))).have.been.calledOnce

    it "replace epic", () ->
        epics = Immutable.fromJS([
            { id: 111 }
            { id: 112 }
        ])

        epicsService._epics = epics

        epic = Immutable.Map({
            id: 112,
            title: "title1"
        })

        epicsService.replaceEpic(epic)

        expect(epicsService._epics.get(1)).to.be.equal(epic)

    it "list related userstories", () ->
        epic = Immutable.fromJS({
            id: 1
        })
        epicsService.listRelatedUserStories(epic)
        expect(mocks.tgResources.userstories.listInEpic.withArgs(epic.get('id'))).have.been.calledOnce

    it "createEpic", () ->
        epicData = {}
        epic = Immutable.fromJS({
            id: 111
            project: 1
        })
        attachments = Immutable.fromJS([
            {file: "f1"},
            {file: "f2"}
        ])

        epicsPostDeferred = $q.defer()
        mocks.tgResources.epics
            .post
            .withArgs({project: 1})
            .returns(epicsPostDeferred.promise)

        epicsPostDeferred.resolve(epic)

        attachmentsServiceDeferred = $q.defer()
        mocks.tgAttachmentsService
            .upload
            .returns(attachmentsServiceDeferred.promise)

        attachmentsServiceDeferred.resolve()

        epicsService.fetchEpics = sinon.stub()
        epicsService.createEpic(epicData, attachments).then () ->
            expect(mocks.tgAttachmentsService.upload.withArgs("f1", 111, 1, "epic")).have.been.calledOnce
            expect(mocks.tgAttachmentsService.upload.withArgs("f2", 111, 1, "epic")).have.been.calledOnce
            expect(epicsService.fetchEpics).have.been.calledOnce

        $rootScope.$apply()

    it "Update epic status", () ->
        epic = Immutable.fromJS({
            id: 1
            version: 1
        })

        mocks.tgResources.epics
            .patch
            .withArgs(1, {status: 33, version: 1})
            .promise()
            .resolve()

        epicsService.replaceEpic = sinon.stub()
        epicsService.updateEpicStatus(epic, 33).then () ->
            expect(epicsService.replaceEpic).have.been.calledOnce

    it "Update epic assigned to", () ->
        epic = Immutable.fromJS({
            id: 1
            version: 1
        })

        mocks.tgResources.epics
            .patch
            .withArgs(1, {assigned_to: 33, version: 1})
            .promise()
            .resolve()

        epicsService.replaceEpic = sinon.stub()
        epicsService.updateEpicAssignedTo(epic, 33).then () ->
            expect(epicsService.replaceEpic).have.been.calledOnce

    it "reorder epic", () ->
      epicsService._epics = Immutable.fromJS([
          {
              id: 1
              epics_order: 1
              version: 1
          },
          {
              id: 2
              epics_order: 2
              version: 1
          },
          {
              id: 3
              epics_order: 3
              version: 1
          },
      ])

      mocks.tgResources.epics.reorder
          .withArgs(3, {epics_order: 2, version: 1}, {1: 1})
          .promise()
          .resolve(Immutable.fromJS({
              id: 3
              epics_order: 3
              version: 2
          }))

      epicsService.reorderEpic(epicsService._epics.get(2), 1)

    it "reorder related userstory in epic", () ->
      epic = Immutable.fromJS({
          id: 1
      })

      epicUserstories = Immutable.fromJS([
          {
              id: 1
              epic_order: 1
          },
          {
              id: 2
              epic_order: 2
          },
          {
              id: 3
              epic_order: 3
          },
      ])

      mocks.tgResources.epics.reorderRelatedUserstory
          .withArgs(1, 3, {order: 2}, {1: 1})
          .promise()
          .resolve()

      epicsService.listRelatedUserStories = sinon.stub()
      epicsService.reorderRelatedUserstory(epic, epicUserstories, epicUserstories.get(2), 1).then () ->
          expect(epicsService.listRelatedUserStories.withArgs(epic)).have.been.calledOnce
