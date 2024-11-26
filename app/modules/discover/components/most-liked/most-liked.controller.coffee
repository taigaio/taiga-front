###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
