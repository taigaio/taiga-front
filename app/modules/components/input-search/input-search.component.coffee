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
