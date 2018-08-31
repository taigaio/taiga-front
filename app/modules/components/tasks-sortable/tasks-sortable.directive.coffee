###
# Copyright (C) 2014-2018 Taiga Agile LLC <taiga@taiga.io>
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
# File: tasks-sortable.directive.coffee
###

TasksSortableDirective = ($parse, projectService) ->
    link = (scope, el, attrs) ->
        return if not projectService.hasPermission("modify_task")

        callback = $parse(attrs.tgTasksSortable)

        drake = dragula([el[0]], {
            copySortSource: false
            copy: false
            mirrorContainer: el[0]
            moves: (item) ->
                return $(item).is('div.single-related-task.js-related-task')
        })

        drake.on 'dragend', (item) ->
            itemEl = $(item)

            task = itemEl.scope().task
            newIndex = itemEl.index()

            scope.$apply () ->
                callback(scope, {task: task, newIndex: newIndex})

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

TasksSortableDirective.$inject = [
    "$parse",
    "tgProjectService"
]

angular.module("taigaComponents").directive("tgTasksSortable", TasksSortableDirective)