###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgDiscoverProjectsService", ->
    discoverProjectsService = provide = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {
            projects: {
                getProjects: sinon.stub()
            },
            stats: {
                discover: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.resources

    _mockProjectsService = () ->
        mocks.projectsService = {
            _decorate: (content) ->
                return content.set('decorate', true)
        }

        provide.value "tgProjectsService", mocks.projectsService

    _inject = (callback) ->
        inject (_tgDiscoverProjectsService_) ->
            discoverProjectsService = _tgDiscoverProjectsService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()
            _mockProjectsService()
            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaDiscover"
        _setup()
        _inject()

    it "fetch most liked", (done) ->
        params = {test: 1, discover_mode: true}

        mocks.resources.projects.getProjects.withArgs(sinon.match(params), false).promise().resolve({
            data: [
                {id: 1},
                {id: 2},
                {id: 3},
                {id: 4},
                {id: 5},
                {id: 6},
                {id: 7}
            ]
        })

        discoverProjectsService.fetchMostLiked(params).then () ->
            result = discoverProjectsService._mostLiked.toJS()

            expect(result).to.have.length(4)
            expect(result[0].decorate).to.be.ok

            done()

    it "fetch most active", (done) ->
        params = {test: 1, discover_mode: true}

        mocks.resources.projects.getProjects.withArgs(sinon.match(params), false).promise().resolve({
            data: [
                {id: 1},
                {id: 2},
                {id: 3},
                {id: 4},
                {id: 5},
                {id: 6},
                {id: 7}
            ]
        })

        discoverProjectsService.fetchMostActive(params).then () ->
            result = discoverProjectsService._mostActive.toJS()

            expect(result).to.have.length(4)
            expect(result[0].decorate).to.be.ok

            done()

    it "fetch featured", (done) ->
        params = {is_featured: true, discover_mode: true}
        mocks.resources.projects.getProjects.withArgs(sinon.match(params), false).promise().resolve({
            data: [
                {id: 1},
                {id: 2},
                {id: 3},
                {id: 4},
                {id: 5},
                {id: 6},
                {id: 7}
            ]
        })

        discoverProjectsService.fetchFeatured().then () ->
            result = discoverProjectsService._featured.toJS()

            expect(result).to.have.length(4)
            expect(result[0].decorate).to.be.ok

            done()

    it "reset search list", () ->
        discoverProjectsService._searchResult = 'xxx'

        discoverProjectsService.resetSearchList()

        expect(discoverProjectsService._searchResult.size).to.be.equal(0)

    it "fetch stats", (done) ->
        mocks.resources.stats.discover.promise().resolve(Immutable.fromJS({
            projects: {
                total: 3
            }
        }))

        discoverProjectsService.fetchStats().then () ->
            expect(discoverProjectsService._projectsCount).to.be.equal(3)

            done()

    it "fetch search", (done) ->
        params = {test: 1, discover_mode: true}

        result = {
            headers: sinon.stub(),
            data: [
                {id: 1},
                {id: 2},
                {id: 3}
            ]
        }

        result.headers.withArgs('X-Pagination-Next').returns('next')

        mocks.resources.projects.getProjects.withArgs(sinon.match(params)).promise().resolve(result)

        discoverProjectsService._searchResult = Immutable.fromJS([
            {id: 4},
            {id: 5}
        ])

        discoverProjectsService.fetchSearch(params).then () ->
            result = discoverProjectsService._searchResult.toJS()

            expect(result).to.have.length(5)

            expect(result[4].decorate).to.be.ok

            done()
