###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

TaskboardZoomDirective = (storage) ->
    link = (scope, el, attrs, ctrl) ->
        scope.zoomIndex = storage.get("taskboard_zoom", 2)

        scope.levels = 4

        zooms = [
            ["assigned_to", "ref"],
            ["subject"],
            ["tags", "extra_info", "unfold", "card-data", "assigned_to_extended"],
            ["related_tasks", "attachments"]
        ]

        getZoomView = (zoomIndex = 0) ->
            zoomIndex = Number(zoomIndex)

            if Number(storage.get("taskboard_zoom")) != zoomIndex
                storage.set("taskboard_zoom", zoomIndex)

            return _.reduce zooms, (result, value, key) ->
                if key <= zoomIndex
                    result = result.concat(value)

                return result

        scope.$watch 'zoomIndex', (zoomLevel) ->
            zoom = getZoomView(zoomLevel)
            scope.onZoomChange({zoomLevel: zoomLevel, zoom: zoom})

    return {
        scope: {
            onZoomChange: "&"
        },
        template: """
        <tg-board-zoom
            levels="levels"
            class="board-zoom"
            value="zoomIndex"
        ></tg-board-zoom>
        """,
        link: link
    }

angular.module('taigaComponents').directive("tgTaskboardZoom", ["$tgStorage", TaskboardZoomDirective])
