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
# File: epics/epics.service.spec.coffee
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

        promise = mocks.tgResources.epics.list.withArgs(1).promise()

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

        promise = mocks.tgResources.epics.list.withArgs(1).promise()

        fetchPromise = epicsService.fetchEpics()

        expect(epicsService._loadingEpics).to.be.true
        expect(epicsService._disablePagination).to.be.true

        promise.resolve(result)

        fetchPromise.then () ->
            expect(epicsService.epics).to.be.equal(result.list)
            expect(epicsService._loadingEpics).to.be.false
            expect(epicsService._disablePagination).to.be.true

    it "fetch epics error", () ->
        epics = Immutable.fromJS([
            { id: 111 }
            { id: 112 }
        ])
        promise = mocks.tgResources.epics.list.withArgs(1).promise().reject(new Error("error"))
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
