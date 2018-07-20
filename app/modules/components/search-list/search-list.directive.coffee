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

        el.on "blur", "#items-filter", (event) ->
            filtering = false

        el.on "focus", "#items-filter", (event) ->
            filtering = true

        scope.filterItems = (searchText) ->
            scope.items = avaliableItems.filter((item) ->
                itemAttrs = item.getAttrs()
                if Array.isArray(scope.filterBy)
                    _.some(scope.filterBy, (attr) -> isContainedIn(searchText, itemAttrs[attr]))
                else
                    isContainedIn(searchText, itemAttrs[scope.filterBy])
            )
            if scope.value
                scope.value = _.find(scope.items, scope.currentSelected)

        scope.$watch 'items', (items) ->
            if !filtering && items?.length
                if scope.resetOnChange
                    scope.currentSelected = null
                    model.$setViewValue(null)
                avaliableItems = angular.copy(items)
                itemsById = groupBy(avaliableItems, (x) -> x.id)

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
            resetOnChange: "="
        }
    }

module.directive('tgSearchList', ['$translate', searchListDirective])
