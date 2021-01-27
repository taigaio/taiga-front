###
# Copyright (C) 2014-present Taiga Agile LLC
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
        drake = null

        $scope.openSwimlane = (id) =>
            containers = _.map $('.kanban-swimlane[data-swimlane="' + id + '"] .taskboard-column'), (item) ->
                return item

            init(containers)

        init = (containers) =>
            if not ($scope.project.my_permissions.indexOf("modify_us") > -1)
                return

            if drake
                containers.forEach (container) =>
                    drake.containers.push(container)

                return
            newParentScope = null
            itemEl = null
            tdom = $el

            deleteElement = (itemEl) ->
                itemEl.off()
                itemEl.remove()

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

            previousCard = null
            nextCard = null

            drake.on 'drop', (item, target, source, sibling) ->
                previousCard = null
                nextCard = null
                prev = $(item).prevAll('tg-card:not(.gu-transit)')
                next = $(item).nextAll('tg-card:not(.gu-transit)')

                previousCard = null
                if prev.length && prev[0].dataset.id
                    previousCard = Number(prev[0].dataset.id)

                nextCard = null
                if !previousCard && next.length && next[0].dataset.id
                    nextCard = Number(next[0].dataset.id)

            drake.on 'dragend', (item, target, source, sibling) ->
                parentEl = item.parentNode
                dragMultipleItems = window.dragMultiple.stop()

                # if it is not drag multiple
                if !dragMultipleItems.length
                    dragMultipleItems = [item]

                firstElementId = dragMultipleItems[0].dataset.id
                firstElement = dragMultipleItems[0]

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
                        oldSwimlaneId = item.getIn(['model', 'swimlane']) || -1
                        sameContainer = newStatus == oldStatus && newSwimlane == oldSwimlaneId

                        if !sameContainer
                            itemEl = $(dragMultipleItems[key])
                            deleteElement(itemEl)

                    $rootscope.$broadcast("kanban:us:move", finalUsList, newStatus, newSwimlane, index, previousCard, nextCard)

            scroll = autoScroll(containers, {
                margin: 100,
                scrollWhenOutside: true,
                autoScroll: () ->
                    return this.down && drake.dragging
            })

        unwatch = $scope.$watch "isTableLoaded", (tableLoaded) ->
            return if !tableLoaded

            isSwimlane = $('.swimlane').length

            # in swimlanes we load every swimlane with kanbanTableLoaded
            return if isSwimlane

            unwatch()

            containers = _.map $el.find('.taskboard-column'), (item) ->
                return item

            init(containers)

        $scope.$on "$destroy", ->
            $el.off()

            if drake
                drake.destroy()

    return {link: link}


module.directive("tgKanbanSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "tgKanbanUserstories",
    KanbanSortableDirective
])
