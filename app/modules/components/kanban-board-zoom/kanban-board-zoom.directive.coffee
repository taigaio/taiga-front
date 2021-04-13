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
