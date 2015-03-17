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
# File: modules/taskboard/sortable.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy

module = angular.module("taigaBacklog")


#############################################################################
## Sortable Directive
#############################################################################

TaskboardSortableDirective = ($repo, $rs, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
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
                handle: ".taskboard-task-inner",
                dropOnEmpty: true
                connectWith: ".taskboard-tasks-box"
                revert: 400
            })

            tdom.on "sortstop", (event, ui) ->
                parentEl = ui.item.parent()
                itemEl = ui.item
                itemTask = itemEl.scope().task
                itemIndex = itemEl.index()
                newParentScope = parentEl.scope()

                oldUsId = if oldParentScope.us then oldParentScope.us.id else null
                oldStatusId = oldParentScope.st.id
                newUsId = if newParentScope.us then newParentScope.us.id else null
                newStatusId = newParentScope.st.id

                if newStatusId != oldStatusId or newUsId != oldUsId
                    deleteElement(itemEl)

                $scope.$apply ->
                    $rootscope.$broadcast("taskboard:task:move", itemTask, newUsId, newStatusId, itemIndex)

                ui.item.find('a').removeClass('noclick')

            tdom.on "sortstart", (event, ui) ->
                oldParentScope = ui.item.parent().scope()
                ui.item.find('a').addClass('noclick')

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgTaskboardSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    TaskboardSortableDirective
])
