###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module("taigaComponents")

normalizeString = @.taiga.normalizeString
groupBy = @.taiga.groupBy

searchListDirective = ($translate) ->
    link = (scope, el, attrs, model) ->
        scope.templateUrl = "components/search-list/search-list-#{scope.itemType}-choice.html"
        scope.currentSelected = null
        filtering = false
        avaliableItems = []
        itemsById = {}

        if scope.itemType == 'issue'
            scope.milestonesById = groupBy(scope.project.milestones, (e) -> e.id)

        if scope.filterClosed
            scope.showClosed = false

            if scope.itemType == 'sprint'
                scope.textShowClosed = $translate.instant("BACKLOG.SPRINTS.ACTION_SHOW_CLOSED_SPRINTS")
                scope.textHideClosed = $translate.instant("BACKLOG.SPRINTS.ACTION_HIDE_CLOSED_SPRINTS")

        el.on "click", ".choice", (event) ->
            choiceId = parseInt($(event.currentTarget).data("choice-id"))
            value = if attrs.ngModel?.id != choiceId then itemsById[choiceId] else null
            model.$setViewValue(value)
            scope.currentSelected = value
            scope.$apply()

        isContainedIn = (needle, haystack) ->
            return _.includes(parseString(haystack), parseString(needle))

        parseString = (value) ->
            if typeof value != 'string'
                value = value.toString()
            return normalizeString(value.toUpperCase())

        resetSelected = () ->
            scope.currentSelected = null
            model.$setViewValue(null)

        resetAll = () ->
            resetSelected()
            scope.searchText = ''
            avaliableItems = angular.copy(scope.items)
            itemsById = groupBy(avaliableItems, (x) -> x.id)


        scope.isVisible = (item) ->
            if !scope.filterClosed || scope.showClosed
                return true
            if (scope.itemType == 'sprint' && (item.closed || item.is_closed))
                if (scope.currentSelected?.id == item.id)
                    resetSelected()
                return false
            return true

        scope.toggleShowClosed = (item) ->
            scope.showClosed = !scope.showClosed

        scope.filterItems = (searchText) ->
            scope.filtering = true
            scope.items = _.filter(avaliableItems, (item) ->
                itemAttrs = item.getAttrs()
                if Array.isArray(scope.filterBy)
                    _.some(scope.filterBy, (attr) -> isContainedIn(searchText, itemAttrs[attr]))
                else
                    isContainedIn(searchText, itemAttrs[scope.filterBy])
            )
            if !_.find(scope.items, scope.currentSelected)
                resetSelected()

        scope.$watch 'items', (items) ->
            if !scope.filtering && items
                resetAll()

    return {
        link: link,
        templateUrl: "components/search-list/search-list.html",
        require: "ngModel",
        scope: {
            label: '@',
            placeholder: '@',
            project: '=',
            filterBy: '=',
            items: '=',
            itemType: '@',
            filterClosed: '=',
            itemDisabled: '='
        }
    }

module.directive('tgSearchList', ['$translate', searchListDirective])
