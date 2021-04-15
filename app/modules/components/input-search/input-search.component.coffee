###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
