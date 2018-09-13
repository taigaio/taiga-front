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
# File: components/filter/filter.controller.coffee
###

class FilterController
    @.$inject = []

    constructor: () ->
        @.opened = null
        @.customFilterForm = false
        @.customFilterName = ''

    toggleFilterCategory: (filterName) ->
        if @.opened == filterName
            @.opened = null
        else
            @.opened = filterName

    isOpen: (filterName) ->
        return @.opened == filterName

    saveCustomFilter: () ->
        @.onSaveCustomFilter({name: @.customFilterName})
        @.customFilterForm = false
        @.opened = 'custom-filter'
        @.customFilterName = ''

    changeQ: () ->
        @.onChangeQ({q: @.q})

    unselectFilter: (filter) ->
        @.onRemoveFilter({filter: filter})

    unselectFilter: (filter) ->
        @.onRemoveFilter({filter: filter})

    selectFilter: (filterCategory, filter) ->
        filter = {
            category: filterCategory
            filter: filter
        }

        @.onAddFilter({filter: filter})

    removeCustomFilter: (filter) ->
        @.onRemoveCustomFilter({filter: filter})

    selectCustomFilter: (filter) ->
        @.onSelectCustomFilter({filter: filter})

    isFilterSelected: (filterCategory, filter) ->
        return !!_.find @.selectedFilters, (it) ->
            return filter.id == it.id && filterCategory.dataType == it.dataType

angular.module('taigaComponents').controller('Filter', FilterController)
