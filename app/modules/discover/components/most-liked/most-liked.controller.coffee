###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class MostLikedController
    @.$inject = [
        "tgDiscoverProjectsService"
    ]

    constructor: (@discoverProjectsService) ->
        taiga.defineImmutableProperty @, "highlighted", () => return @discoverProjectsService.mostLiked

        @.currentOrderBy = 'year'
        @.order_by = @.getOrderBy()

    fetch: () ->
        @.loading = true
        @.order_by = @.getOrderBy()

        @discoverProjectsService.fetchMostLiked({order_by: @.order_by}).then () =>
            @.loading = false

    orderBy: (type) ->
        @.currentOrderBy = type

        @.fetch()

    getOrderBy: () ->
        if @.currentOrderBy == 'all'
            return '-total_fans'
        else
            return '-total_fans_last_' + @.currentOrderBy

angular.module("taigaDiscover").controller("MostLiked", MostLikedController)
