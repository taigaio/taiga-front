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
# File: discover/components/most-active/most-active.controller.coffee
###

class MostActiveController
    @.$inject = [
        "tgDiscoverProjectsService"
    ]

    constructor: (@discoverProjectsService) ->
        taiga.defineImmutableProperty @, "highlighted", () => return @discoverProjectsService.mostActive

        @.currentOrderBy = 'week'
        @.order_by = @.getOrderBy()

    fetch: () ->
        @.loading = true
        @.order_by = @.getOrderBy()

        return @discoverProjectsService.fetchMostActive({order_by: @.order_by}).then () =>
            @.loading = false

    orderBy: (type) ->
        @.currentOrderBy = type

        @.fetch()

    getOrderBy: (type) ->
        if @.currentOrderBy == 'all'
            return '-total_activity'
        else
            return '-total_activity_last_' + @.currentOrderBy

angular.module("taigaDiscover").controller("MostActive", MostActiveController)
