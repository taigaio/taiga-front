###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
