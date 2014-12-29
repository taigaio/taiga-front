###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/kanban/sortable.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy
timeout = @.taiga.timeout

module = angular.module("taigaKanban")


#############################################################################
## Sortable Directive
#############################################################################

KanbanSortableDirective = ($repo, $rs, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "project", (project) ->
            if not (project.my_permissions.indexOf("modify_us") > -1)
                return

            oldParentScope = null
            newParentScope = null
            itemEl = null
            tdom = $el

            deleteElement = (itemEl) ->
                # Completelly remove item and its scope from dom
                itemEl.scope().$destroy()
                itemEl.off()
                itemEl.remove()

            tdom.sortable({
                handle: ".kanban-task-inner"
                dropOnEmpty: true
                connectWith: ".kanban-uses-box"
                revert: 400
            })

            tdom.on "sortstop", (event, ui) ->
                parentEl = ui.item.parent()
                itemEl = ui.item
                itemUs = itemEl.scope().us
                itemIndex = itemEl.index()
                newParentScope = parentEl.scope()

                newStatusId = newParentScope.s.id
                oldStatusId = oldParentScope.s.id

                if newStatusId != oldStatusId
                    deleteElement(itemEl)

                $scope.$apply ->
                    $rootscope.$broadcast("kanban:us:move", itemUs, itemUs.status, newStatusId, itemIndex)

                ui.item.find('a').removeClass('noclick')

            tdom.on "sortstart", (event, ui) ->
                oldParentScope = ui.item.parent().scope()
                ui.item.find('a').addClass('noclick')

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgKanbanSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    KanbanSortableDirective
])
