###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

EpicsSortableDirective = ($parse, projectService) ->
    link = (scope, el, attrs) ->
        return if not projectService.hasPermission("modify_epic")

        callback = $parse(attrs.tgEpicsSortable)

        drake = dragula([el[0]], {
            copySortSource: false
            copy: false
            mirrorContainer: el[0]
            moves: (item) ->
                return $(item).is('div.epics-table-body-row')
        })

        drake.on 'dragend', (item) ->
            itemEl = $(item)

            epic = itemEl.scope().epic
            newIndex = itemEl.index()

            scope.$apply () ->
                callback(scope, {epic: epic, newIndex: newIndex})

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

EpicsSortableDirective.$inject = [
    "$parse",
    "tgProjectService"
]

angular.module("taigaComponents").directive("tgEpicsSortable", EpicsSortableDirective)
