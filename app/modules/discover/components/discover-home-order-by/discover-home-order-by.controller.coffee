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
