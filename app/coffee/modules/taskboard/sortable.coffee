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

TaskboardSortableDirective = ($repo, $rs, $rootscope, $translate) ->
    link = ($scope, $el, $attrs) ->
        unwatch = $scope.$watch "usTasks", (usTasks) ->
            return if !usTasks || !usTasks.size

            unwatch()

            if not ($scope.project.my_permissions.indexOf("modify_task") > -1)
                return

            oldParentScope = null
            newParentScope = null
            itemEl = null
            tdom = $el

            filterError = ->
                text = $translate.instant("BACKLOG.SORTABLE_FILTER_ERROR")
                $tgConfirm.notify("error", text)

            deleteElement = (itemEl) ->
                # Completelly remove item and its scope from dom
                itemEl.scope().$destroy()
                itemEl.off()
                itemEl.remove()

            containers = _.map $el.find('.taskboard-column'), (item) ->
                return item

            drake = dragula(containers, {
                copySortSource: false,
                copy: false,
                accepts: (el, target) -> return !$(target).hasClass('taskboard-row-title-box')
                moves: (item) ->
                    return $(item).is('tg-card')
            })

            drake.on 'drag', (item) ->
                oldParentScope = $(item).parent().scope()

                if $el.hasClass("active-filters")
                    filterError()

                    setTimeout (() ->
                        drake.cancel(true)
                    ), 0

                    return false

            drake.on 'dragend', (item) ->
                parentEl = $(item).parent()
                itemEl = $(item)
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
                    $rootscope.$broadcast("taskboard:task:move", itemTask, itemTask.getIn(['model', 'status']), newUsId, newStatusId, itemIndex)


            scroll = autoScroll([$('.taskboard-table-body')[0]], {
                margin: 100,
                pixels: 30,
                scrollWhenOutside: true,
                autoScroll: () ->
                    return this.down && drake.dragging
            })

            $scope.$on "$destroy", ->
                $el.off()
                drake.destroy()

    return {link: link}


module.directive("tgTaskboardSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "$translate",
    TaskboardSortableDirective
])
