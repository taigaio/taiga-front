###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module('taigaEpics')

RelatedUserstoriesSortableDirective = ($parse, projectService) ->
    link = (scope, el, attrs) ->
        return if not projectService.hasPermission("modify_epic")

        callback = $parse(attrs.tgRelatedUserstoriesSortable)

        drake = dragula([el[0]], {
            copySortSource: false
            copy: false
            mirrorContainer: el[0]
            moves: (item) ->
                return $(item).is('tg-related-userstory-row')
        })

        drake.on 'dragend', (item) ->
            itemEl = $(item)
            us = itemEl.scope().us
            newIndex = itemEl.index()

            scope.$apply () ->
                callback(scope, {us: us, newIndex: newIndex})

        scroll = autoScroll(window, {
            margin: 20,
            pixels: 30,
            scrollWhenOutside: true,
            autoScroll: () ->
                return this.down && drake.dragging
        })

        scope.$on "$destroy", ->
            el.off()
            drake.destroy()

    return {
        link: link
    }

RelatedUserstoriesSortableDirective.$inject = [
    "$parse",
    "tgProjectService"
]

module.directive("tgRelatedUserstoriesSortable", RelatedUserstoriesSortableDirective)
