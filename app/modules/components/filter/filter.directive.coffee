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
# File: components/filter/filter.directive.coffee
###

FilterDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        unwatch = scope.$watch "vm.defaultQ", (q) ->
            if q && !scope.vm.filtersForm.$dirty
                scope.vm.q = q
                unwatch()
            else if scope.vm.filtersForm.$dirty
                unwatch()

        attrs.$observe "open", (open) ->
            open = scope.$eval(open)

            if open
                el.addClass('open')
            else
                el.removeClass('open')

    return {
        scope: {
            onChangeQ: "&",
            onAddFilter: "&",
            onSelectCustomFilter: "&",
            onRemoveFilter: "&",
            onRemoveCustomFilter: "&",
            onSaveCustomFilter: "&",
            customFilters: "<",
            defaultQ: "=q",
            filters: "<"
            customFilters: "<"
            selectedFilters: "<"
        },
        bindToController: true,
        controller: "Filter",
        controllerAs: "vm",
        templateUrl: 'components/filter/filter.html',
        link: link
    }

angular.module('taigaComponents').directive("tgFilter", [FilterDirective])
