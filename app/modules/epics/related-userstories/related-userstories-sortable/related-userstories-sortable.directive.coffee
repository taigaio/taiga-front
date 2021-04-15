###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
