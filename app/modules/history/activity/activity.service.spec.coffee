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
# File: history/activity/activity.service.spec.coffee
###


describe "tgActivityService", ->
    $provide = null
    activityService = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            history: {
                getHistory: sinon.stub()
            }
        }
        $provide.value("tgResources", mocks.tgResources)

    _mockXhrErrorService = () ->
        mocks.xhrErrorService = {
            response: sinon.stub()
        }

        $provide.value "tgXhrErrorService", mocks.xhrErrorService

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTgResources()
            _mockXhrErrorService()

            return null

    _inject = ->
        inject (_tgActivityService_) ->
            activityService = _tgActivityService_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaHistory"

        _setup()

    fixtures = {
        contentType: 'foo',
        objId: 43,
        page: 1,
        response: {
            headers: sinon.stub()
            list: Immutable.List([
                {id: 1, name: 'history entry 1'},
                {id: 2, name: 'history entry 2'},
                {id: 3, name: 'history entry 3'},
            ])
        }
    }

    it "populate history entries", (done) ->
        f = fixtures
        mocks.tgResources.history.getHistory.withArgs('activity', f.contentType, f.objId, f.page)
            .promise().resolve(f.response)

        activityService.init(f.contentType, f.objId)
        expect(activityService._objectId).to.be.equal(f.objId)

        expect(activityService.entries.size).to.be.equal(0)
        activityService.fetchEntries().then () ->
            expect(activityService.entries.size).to.be.equal(3)
            done()

    it "reset history entries if objectId change", () ->
        f = fixtures
        activityService.entries = f.response.list
        expect(activityService.entries.size).to.be.equal(3)

        activityService.init(f.contentType, f.objId + 1)
        expect(activityService.entries.size).to.be.equal(0)
