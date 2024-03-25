###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
