###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgEpicsResource", ->
    epicsResource = $q = $rootScope = null
    mocks = {}

    beforeEach ->
        module "taigaResources2"

        module ($provide) ->
            mocks.urls = {resolve: sinon.stub().returns("/api/epics")}
            mocks.http = {get: sinon.stub()}
            $provide.value "$tgUrls", mocks.urls
            $provide.value "$tgHttp", mocks.http
            return null

        inject (_tgEpicsResource_, _$q_, _$rootScope_) ->
            epicsResource = _tgEpicsResource_().epics
            $q = _$q_
            $rootScope = _$rootScope_
            mocks.http.get.returns($q.when({data: [], headers: sinon.stub()}))

    it "lists epics without filters", ->
        epicsResource.list(42)

        expect(mocks.http.get).to.have.been.calledWith("/api/epics", {project: 42})

    it "passes filter and page params to the epic list", ->
        params = {
            page: 3
            q: "authentication"
            status: "1"
            exclude_status: "2"
            assigned_to: "7"
            owner: "4"
            tags: "Backend"
            exclude_tags: "Legacy"
        }

        epicsResource.list(42, params)

        expect(mocks.http.get.firstCall.args).to.deep.equal([
            "/api/epics"
            _.assign({project: 42}, params)
        ])

    it "loads facet counts with the active filter params", ->
        params = {
            project: 42
            q: "authentication"
            assigned_to: "7"
            exclude_status: "2"
            exclude_tags: "Legacy"
        }

        response = {statuses: []}
        mocks.http.get.returns($q.when({data: response}))

        actualData = null
        epicsResource.filtersData(params).then (data) -> actualData = data
        $rootScope.$apply()

        expect(mocks.urls.resolve).to.have.been.calledWith("epics")
        expect(mocks.http.get.firstCall.args).to.deep.equal([
            "/api/epics/filters_data"
            params
        ])
        expect(actualData).to.deep.equal(response)
