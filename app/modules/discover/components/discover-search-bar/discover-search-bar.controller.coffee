class DiscoverSearchBarController
    @.$inject = [
        'tgDiscoverProjectsService'
    ]

    constructor: (@discoverProjectsService) ->
        taiga.defineImmutableProperty @, 'projects', () => return @discoverProjectsService.projectsCount

        @discoverProjectsService.fetchStats()

    selectFilter: (filter) ->
        @.onChange({filter: filter, q: @.q})

    submitFilter: ->
        @.onChange({filter: @.filter, q: @.q})

angular.module("taigaDiscover").controller("DiscoverSearchBar", DiscoverSearchBarController)
