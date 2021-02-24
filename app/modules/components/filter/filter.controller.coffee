###
# Copyright (C) 2014-present Taiga Agile LLC
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
# File: components/filter/filter.controller.coffee
###

class FilterController
    @.$inject = [
        '$translate',
    ]

    @.activeCustomFilter = null
    @.repeatedFilterError = false
    @.lengthZeroError = false

    constructor: (@translate) ->
        @.opened = null
        @.filterModeOptions = ["include", "exclude"]
        @.filterModeLabels = {
            "include": @translate.instant("COMMON.FILTERS.ADVANCED_FILTERS.INCLUDE"),
            "exclude": @translate.instant("COMMON.FILTERS.ADVANCED_FILTERS.EXCLUDE"),
        }
        @.filterMode = 'include'
        @.customFilterForm = false
        @.customFilterName = ''

        @.$onChanges = (changes) ->
            if changes.selectedFilters
                @.getIncludedFilters()
                @.getExcludedFilters()

        @.includedFilters = @.getIncludedFilters()
        @.excludedFilters = @.getExcludedFilters()


    toggleFilterCategory: (filterName) ->
        if @.opened == filterName
            @.opened = null
        else
            @.opened = filterName

    isOpen: (filterName) ->
        return @.opened == filterName

    openCustomFilter: () ->
        @.customFilterForm = true
        @.lengthZeroError = false
        @.repeatedFilterError = false

    saveCustomFilter: () ->
        if @.customFilterName.length > 0 && !@.customFilters.find((filter) => filter.name == @.customFilterName)
            @.lengthZeroError = false
            @.repeatedFilterError = false
            @.onSaveCustomFilter({name: @.customFilterName})
            @.customFilterForm = false
            @.opened = 'custom-filter'
            @.customFilterName = ''

        if @.customFilterName.length == 0
            @.lengthZeroError = true
        else
            @.lengthZeroError = false

        if !@.customFilters.find((filter) => filter.name == @.customFilterName)
            @.repeatedFilterError = false
        else
            @.repeatedFilterError = true

    unselectFilter: (filter) ->
        @.activeCustomFilter = null
        @.onRemoveFilter({filter: filter})

    selectFilter: (filterCategory, filter) ->
        filter = {
            category: filterCategory
            filter: filter
            mode: @.filterMode
        }
        @.activeCustomFilter = null
        @.onAddFilter({filter: filter})

    removeCustomFilter: (filter) ->
        @.activeCustomFilter = null
        @.onRemoveCustomFilter({filter: filter})

    selectCustomFilter: (filter) ->
        @.activeCustomFilter = filter.id
        @.onSelectCustomFilter({filter: filter})

    getIncludedFilters: () ->
        @.includedFilters = _.filter @.selectedFilters, (it) ->
            return it.mode == 'include'

    getExcludedFilters: () ->
        @.excludedFilters = _.filter @.selectedFilters, (it) ->
            return it.mode == 'exclude'

    isFilterSelected: (filterCategory, filter) ->
        return !!_.find @.selectedFilters, (it) ->
            return filter.id == it.id && filterCategory.dataType == it.dataType

angular.module('taigaComponents').controller('Filter', FilterController)
