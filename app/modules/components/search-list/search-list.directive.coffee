###
# Copyright (C) 2014-2018 Taiga Agile LLC <taiga@taiga.io>
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
# File: search-list.directive.coffee
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
