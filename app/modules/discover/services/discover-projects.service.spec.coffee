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
# File: discover/services/discover-projects.service.spec.coffee
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

            expect(result).to.have.length(5)
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

            expect(result).to.have.length(5)
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
