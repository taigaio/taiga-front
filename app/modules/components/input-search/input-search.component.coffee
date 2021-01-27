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
# File: components/input-search/input-search.component.coffee
###

InputSearchComponent =
  bindings: {
    q: '<',
    change: '&'
  },
  template: """
    <input
        type="search"
        placeholder="{{'COMMON.FILTERS.INPUT_PLACEHOLDER' | translate}}"
        ng-model="$ctrl.searchText"
        ng-change="$ctrl.onChange($ctrl.searchText)" />
    <tg-svg svg-icon="icon-search"></tg-svg>
  """,
  controller: ->
    @.searchText = ''
    @.dirty = false

    @.$onChanges = (changes) ->
        if changes.q && !@.dirty
            @.searchText = @.q

    @.onChange = (text) =>
        @.dirty = true
        @.change({q: text})

    return

angular.module("taigaComponents").component("tgInputSearch", InputSearchComponent)
