###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
