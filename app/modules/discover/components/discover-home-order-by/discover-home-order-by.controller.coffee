###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
