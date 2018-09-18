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
# File: discover/components/discover-home-order-by/discover-home-order-by.controller.coffee
###

class DiscoverHomeOrderByController
    @.$inject = [
        '$translate'
    ]

    constructor: (@translate) ->
        @.is_open = false

        @.texts = {
            week: @translate.instant('DISCOVER.FILTERS.WEEK'),
            month: @translate.instant('DISCOVER.FILTERS.MONTH'),
            year: @translate.instant('DISCOVER.FILTERS.YEAR'),
            all: @translate.instant('DISCOVER.FILTERS.ALL_TIME')
        }

    currentText: () ->
        return @.texts[@.currentOrderBy]

    open: () ->
        @.is_open = true

    close: () ->
        @.is_open = false

    orderBy: (type) ->
        @.currentOrderBy = type
        @.is_open = false
        @.onChange({orderBy: @.currentOrderBy})

angular.module("taigaDiscover").controller("DiscoverHomeOrderBy", DiscoverHomeOrderByController)
