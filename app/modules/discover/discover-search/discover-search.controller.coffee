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
# File: discover/discover-search/discover-search.controller.coffee
###

class DiscoverSearchController
    @.$inject = [
        '$routeParams',
        'tgDiscoverProjectsService',
        '$route',
        '$tgLocation',
        '$tgAnalytics',
        'tgAppMetaService',
        '$translate'
    ]

    constructor: (@routeParams, @discoverProjectsService, @route, @location, @analytics, @appMetaService, @translate) ->
        @.page = 1

        taiga.defineImmutableProperty @, "searchResult", () => return @discoverProjectsService.searchResult
        taiga.defineImmutableProperty @, "nextSearchPage", () => return @discoverProjectsService.nextSearchPage

        @.q = @routeParams.text
        @.filter = @routeParams.filter || 'all'
        @.orderBy = @routeParams['order_by'] || ''

        @.loadingGlobal = false
        @.loadingList = false
        @.loadingPagination = false

        title = @translate.instant("DISCOVER.SEARCH.PAGE_TITLE")
        description = @translate.instant("DISCOVER.SEARCH.PAGE_DESCRIPTION")
        @appMetaService.setAll(title, description)
        @analytics.trackPage(@location.url(), "Discover Search")

    fetch: () ->
        @.page = 1

        @discoverProjectsService.resetSearchList()

        return @.search()

    fetchByGlobalSearch: () ->
        return if @.loadingGlobal

        @.loadingGlobal = true

        @.fetch().then () => @.loadingGlobal = false

    fetchByOrderBy: () ->
        return if @.loadingList

        @.loadingList = true

        @.fetch().then () => @.loadingList = false

    showMore: () ->
        return if @.loadingPagination

        @.loadingPagination = true

        @.page++

        return @.search().then () => @.loadingPagination = false

    search: () ->
        filter = @.getFilter()

        params = {
            page: @.page,
            q: @.q,
            order_by: @.orderBy
        }

        _.assign(params, filter)

        return @discoverProjectsService.fetchSearch(params)

    getFilter: () ->
        if @.filter == 'people'
            return {is_looking_for_people: true}
        else if @.filter == 'scrum'
            return {is_backlog_activated: true}
        else if @.filter == 'kanban'
            return {is_kanban_activated: true}

        return {}

    onChangeFilter: (filter, q) ->
        @.filter = filter
        @.q = q

        @route.updateParams({
            filter: @.filter,
            text: @.q
        })
        @analytics.trackPage(@location.url(), "Discover Search")

        @.fetchByGlobalSearch()

    onChangeOrder: (orderBy) ->
        @.orderBy = orderBy

        @route.updateParams({
            order_by: orderBy
        })
        @analytics.trackPage(@location.url(), "Discover Search")

        @.fetchByOrderBy()

angular.module("taigaDiscover").controller("DiscoverSearch", DiscoverSearchController)
