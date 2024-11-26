###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "RelatedUserStories", ->
    RelatedUserStoriesCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgEpicsService = () ->
        mocks.tgEpicsService = {
            listRelatedUserStories: sinon.stub()
            reorderRelatedUserstory: sinon.stub()
        }

        provide.value "tgEpicsService", mocks.tgEpicsService

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            hasPermission: sinon.stub()
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgEpicsService()
            _mockTgProjectService()
            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "load related userstories", (done) ->
        ctrl = controller "RelatedUserStoriesCtrl"
        userstories = Immutable.fromJS([
            {
                id: 1
            }
        ])

        ctrl.epic = Immutable.fromJS({
            id: 66
        })

        promise = mocks.tgEpicsService.listRelatedUserStories
            .withArgs(ctrl.epic)
            .promise()
            .resolve(userstories)

        ctrl.loadRelatedUserstories().then () ->
            expect(ctrl.userstories).is.equal(userstories)
            done()

    it "reorderRelatedUserstory", (done) ->
        ctrl = controller "RelatedUserStoriesCtrl"
        userstories = Immutable.fromJS([
            {
                id: 1
            },
            {
                id: 2
            }
        ])

        reorderedUserstories = Immutable.fromJS([
            {
                id: 2
            },
            {
                id: 1
            }
        ])

        ctrl.epic = Immutable.fromJS({
            id: 66
        })

        promise = mocks.tgEpicsService.reorderRelatedUserstory
            .withArgs(ctrl.epic, ctrl.userstories, userstories.get(1), 0)
            .promise()
            .resolve(reorderedUserstories)

        ctrl.reorderRelatedUserstory(userstories.get(1), 0).then () ->
            expect(ctrl.userstories).is.equal(reorderedUserstories)
            done()
