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
# File: discover/components/discover-search-list-header/discover-search-list-header.controller.coffee
###

class DiscoverSearchListHeaderController
    @.$inject = []

    constructor: () ->
        @.like_is_open = @.orderBy.indexOf('-total_fans') == 0
        @.activity_is_open = @.orderBy.indexOf('-total_activity') == 0

    openLike: () ->
        @.like_is_open = true
        @.activity_is_open = false

        @.setOrderBy('-total_fans_last_week')

    openActivity: () ->
        @.activity_is_open = true
        @.like_is_open = false

        @.setOrderBy('-total_activity_last_week')

    setOrderBy: (type = '') ->
        if !type
            @.like_is_open = false
            @.activity_is_open = false

        @.onChange({orderBy: type})

angular.module("taigaDiscover").controller("DiscoverSearchListHeader", DiscoverSearchListHeaderController)
