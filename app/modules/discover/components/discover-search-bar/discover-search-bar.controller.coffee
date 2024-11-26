###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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
