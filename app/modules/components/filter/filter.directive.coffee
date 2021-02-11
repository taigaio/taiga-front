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
# File: components/filter/filter.directive.coffee
###

FilterDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        watchTaskboardHeight = (taskboard) =>
            resizeObserver = new ResizeObserver () =>
                maxSize = null
                currentMax = Number(el[0].style.getPropertyValue('--filter-list-max-height').replace('px', ''))

                if scope.vm.opened
                    maxSize = taskboard.offsetHeight - el[0].offsetHeight + currentMax
                else
                    maxSize = taskboard.offsetHeight - el[0].offsetHeight

                if maxSize < 100
                    maxSize = 100
                else if maxSize > 380
                    maxSize = 380

                el[0].style.setProperty('--filter-list-max-height', maxSize + "px")

                resizeObserver.unobserve(el[0]);

            resizeObserver.observe(taskboard);

        attrs.$observe "open", (open) ->
            open = scope.$eval(open)

            if open
                el.addClass('open')
            else
                el.removeClass('open')

        taskboard = $('.js-taskboard-manager')
        if taskboard.length
            watchTaskboardHeight(taskboard[0])

    return {
        scope: {
            onChangeQ: "&",
            onAddFilter: "&",
            onSelectCustomFilter: "&",
            onRemoveFilter: "&",
            onRemoveCustomFilter: "&",
            onSaveCustomFilter: "&",
            customFilters: "<",
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
