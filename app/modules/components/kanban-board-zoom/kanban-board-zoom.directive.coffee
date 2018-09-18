###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: components/kanban-board-zoom/kanban-board-zoom.directive.coffee
###

KanbanBoardZoomDirective = (storage, projectService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.zoomIndex = storage.get("kanban_zoom") or 2
        scope.levels = 5

        zooms = [
            ["ref"],
            ["subject"],
            ["owner", "tags", "extra_info", "unfold"],
            ["attachments"],
            ["related_tasks", "empty_extra_info"]
        ]

        getZoomView = (zoomIndex = 0) ->
            if storage.get("kanban_zoom") != zoomIndex
                storage.set("kanban_zoom", zoomIndex)

            return _.reduce zooms, (result, value, key) ->
                if key <= zoomIndex
                    result = result.concat(value)

                return result

        scope.$watch 'zoomIndex', (zoomLevel) ->
            zoom = getZoomView(zoomLevel)
            scope.onZoomChange({zoomLevel: zoomLevel, zoom: zoom})

        unwatch = scope.$watch () ->
            return projectService.project
        , (project) ->
            if project
                if project.get('my_permissions').indexOf("view_tasks") == -1
                    scope.levels = 4
                unwatch()

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
