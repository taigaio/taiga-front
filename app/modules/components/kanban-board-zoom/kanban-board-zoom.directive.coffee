###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

KanbanBoardZoomDirective = (storage, projectService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.zoomIndex = storage.get("kanban_zoom", 1)

        scope.levels = 4

        zooms = [
            ["assigned_to", "ref"],
            ["subject", "card-data", "assigned_to_extended"],
            ["tags", "extra_info", "unfold"],
            ["related_tasks", "attachments"]
        ]

        getZoomView = (zoomIndex = 0) ->
            if zoomIndex > 3
                zoomIndex = 3

            zoomIndex = Number(zoomIndex)

            if Number(storage.get("kanban_zoom")) != zoomIndex
                storage.set("kanban_zoom", zoomIndex)

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
            class="board-zoom"
            value="zoomIndex"
            levels="levels"
        ></tg-board-zoom>
        """,
        link: link
    }

angular.module('taigaComponents').directive("tgKanbanBoardZoom", ["$tgStorage", "tgProjectService", KanbanBoardZoomDirective])
