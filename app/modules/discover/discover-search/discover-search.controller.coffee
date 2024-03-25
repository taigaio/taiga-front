###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
