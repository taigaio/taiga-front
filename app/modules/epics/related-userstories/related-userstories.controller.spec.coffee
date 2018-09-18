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
# File: epics/related-userstories/related-userstories.controller.spec.coffee
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
