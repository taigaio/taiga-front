###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
