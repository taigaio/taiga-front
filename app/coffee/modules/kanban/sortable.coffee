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

KanbanSortableDirective = ($repo, $rs, $rootscope, kanbanUserstoriesService) ->
    link = ($scope, $el, $attrs) ->
        unwatch = $scope.$watch "isTableLoaded", (tableLoaded) ->
            return if !tableLoaded || !kanbanUserstoriesService.usByStatus?.size

            unwatch()

            if not ($scope.project.my_permissions.indexOf("modify_us") > -1)
                return

            newParentScope = null
            itemEl = null
            tdom = $el

            deleteElement = (itemEl) ->
                itemEl.off()
                itemEl.remove()

            containers = _.map $el.find('.taskboard-column'), (item) ->
                return item

            drake = dragula(containers, {
                copySortSource: false,
                copy: false,
                moves: (item) ->
                    return $(item).is('tg-card')
            })

            initialContainer = null

            drake.on 'over', (item, container) ->
                if !initialContainer
                    initialContainer = container
                else if container != initialContainer
                    $(container).addClass('target-drop')

            drake.on 'out', (item, container) ->
                if container != initialContainer
                    $(container).removeClass('target-drop')

            drake.on 'drag', (item) ->
                initialContainer = null
                window.dragMultiple.start(item, containers)

            drake.on 'cloned', (item, dropTarget) ->
                $(item).addClass('multiple-drag-mirror')

            drake.on 'dragend', (item) ->

                parentEl = item.parentNode
                dragMultipleItems = window.dragMultiple.stop()

                # if it is not drag multiple
                if !dragMultipleItems.length
                    dragMultipleItems = [item]

                firstElement = dragMultipleItems[0]

                previousCard = null
                if firstElement.previousElementSibling && firstElement.previousElementSibling.dataset.id
                    previousCard = Number(firstElement.previousElementSibling.dataset.id)

                index = $(parentEl).find('tg-card').index(firstElement)
                newStatus = Number(parentEl.dataset.status)
                newSwimlane = Number(parentEl.dataset.swimlane)

                if initialContainer != parentEl
                    $(parentEl).addClass('new')

                    $(parentEl).one 'animationend', ()  ->
                        $(parentEl).removeClass('new')

                usList = _.map dragMultipleItems, (item) ->
                    return kanbanUserstoriesService.usMap.get(Number(item.dataset.id))

                finalUsList = _.map usList, (item)  ->
                    return {
                        id: item.get('id'),
                        oldStatusId: item.getIn(['model', 'status'])
                        oldSwimlaneId: item.getIn(['model', 'swimlane'])
                    }

                $scope.$apply ->
                    _.each usList, (item, key) =>
                        oldStatus = item.getIn(['model', 'status'])
                        oldSwimlaneId = item.getIn(['model', 'swimlane'])
                        sameContainer = newStatus == oldStatus && newSwimlane == oldSwimlaneId

                        if !sameContainer
                            itemEl = $(dragMultipleItems[key])
                            deleteElement(itemEl)

                    $rootscope.$broadcast("kanban:us:move", finalUsList, newStatus, newSwimlane, index, previousCard)

            scroll = autoScroll(containers, {
                margin: 100,
                scrollWhenOutside: true,
                autoScroll: () ->
                    return this.down && drake.dragging
            })

            $scope.$on "$destroy", ->
                $el.off()
                drake.destroy()

    return {link: link}


module.directive("tgKanbanSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "tgKanbanUserstories",
    KanbanSortableDirective
])
