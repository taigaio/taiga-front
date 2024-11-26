###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

class DiscoverProjectsService extends taiga.Service
    @.$inject = [
        "tgResources",
        "tgProjectsService"
    ]

    _discoverParams = {
        discover_mode: true
    }

    constructor: (@rs, @projectsService) ->
        @._mostLiked = Immutable.List()
        @._mostActive = Immutable.List()
        @._featured = Immutable.List()
        @._searchResult = Immutable.List()
        @._projectsCount = 0

        @.decorate = @projectsService._decorate.bind(@projectsService)

        taiga.defineImmutableProperty @, "mostLiked", () => return @._mostLiked
        taiga.defineImmutableProperty @, "mostActive", () => return @._mostActive
        taiga.defineImmutableProperty @, "featured", () => return @._featured
        taiga.defineImmutableProperty @, "searchResult", () => return @._searchResult
        taiga.defineImmutableProperty @, "nextSearchPage", () => return @._nextSearchPage
        taiga.defineImmutableProperty @, "projectsCount", () => return @._projectsCount

    fetchMostLiked: (params) ->
        _params = _.extend({}, _discoverParams, params)
        return @rs.projects.getProjects(_params, false)
            .then (result) =>
                data = result.data.slice(0, 4)

                projects = Immutable.fromJS(data)
                projects = projects.map(@.decorate)

                @._mostLiked = projects

    fetchMostActive: (params) ->
        _params = _.extend({}, _discoverParams, params)
        return @rs.projects.getProjects(_params, false)
            .then (result) =>
                data = result.data.slice(0, 4)

                projects = Immutable.fromJS(data)
                projects = projects.map(@.decorate)

                @._mostActive = projects

    fetchFeatured: () ->
        _params = _.extend({}, _discoverParams)
        _params.is_featured = true

        return @rs.projects.getProjects(_params, false)
            .then (result) =>
                data = result.data.slice(0, 4)

                projects = Immutable.fromJS(data)
                projects = projects.map(@.decorate)

                @._featured = projects

    resetSearchList: () ->
        @._searchResult = Immutable.List()

    fetchStats: () ->
        return @rs.stats.discover().then (discover) =>
            @._projectsCount = discover.getIn(['projects', 'total'])

    fetchSearch: (params) ->
        _params = _.extend({}, _discoverParams, params)
        return @rs.projects.getProjects(_params)
            .then (result) =>
                @._nextSearchPage = !!result.headers('X-Pagination-Next')

                projects = Immutable.fromJS(result.data)
                projects = projects.map(@.decorate)

                @._searchResult = @._searchResult.concat(projects)

angular.module("taigaDiscover").service("tgDiscoverProjectsService", DiscoverProjectsService)
