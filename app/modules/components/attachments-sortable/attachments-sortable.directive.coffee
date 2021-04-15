###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

AttachmentSortableDirective = ($parse) ->
    link = (scope, el, attrs) ->
        callback = $parse(attrs.tgAttachmentsSortable)

        drake = dragula([el[0]], {
            copySortSource: false,
            copy: false,
            mirrorContainer: el[0],
            moves: (item) -> return $(item).is('div[tg-bind-scope]')
        })

        drake.on 'dragend', (item) ->
            item = $(item)

            attachment = item.scope().attachment
            newIndex = item.index()

            scope.$apply () ->
                callback(scope, {attachment: attachment, index: newIndex})

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

AttachmentSortableDirective.$inject = [
    "$parse"
]

angular.module("taigaComponents").directive("tgAttachmentsSortable", AttachmentSortableDirective)
