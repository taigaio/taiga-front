###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
