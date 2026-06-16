###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce

module = angular.module("taigaBacklog")


#############################################################################
## Sortable Directive
#############################################################################

TaskboardUsSortableDirective = () ->
    link = ($scope, $el, $attrs) ->
        if !$scope.ctrl
            console.error('BacklogSortableDirective must have access to to BacklogCtrl')

        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
            if not (project.my_permissions.indexOf("modify_us") > -1)
                return

            initIsBacklog = false
            emptyBacklog = $('.js-empty-backlog')
            previousUs = null
            nextUs = null
            oldIndex = null

            drake = dragula([$el[0], emptyBacklog[0], emptyBacklog[1]], {
                copySortSource: false,
                copy: false,
                isContainer: (el) ->
                    return $(el).hasClass('taskboard-draggable-rows')
                moves: (item, source, handle, sibling) -> 
                    return $(handle).is('.taskboard-us')
            })

            drake.on 'drop', (item, target, source, sibling) ->
                previousUs = null
                nextUs = null

                prev = $(item).prevAll('.taskboard-row:not(.gu-transit)')
                next = $(item).nextAll('.taskboard-row:not(.gu-transit)')

                previousUs = null
                if prev.length && prev[0].dataset.id
                    previousUs = Number(prev[0].dataset.id)

                nextUs = null
                if !previousUs && next.length && next[0].dataset.id
                    nextUs = Number(next[0].dataset.id)

            drake.on 'drag', (item, container) ->
                parent = $(item).parent()
                $(document.body).addClass("drag-active")
                
                window.dragMultiple.start(item, container)
                dragMultipleItems = window.dragMultiple.getElements()
                
                firstElement = if dragMultipleItems.length then dragMultipleItems[0] else item
                
                parentEl = item.parentNode
                oldIndex = $(firstElement).index()

            drake.on 'cloned', (item) ->
                $(item).addClass('multiple-drag-mirror')

            drake.on 'dragend', (item) ->
                $('.doom-line').remove()

                parent = $(item).parent()

                dragMultipleItems = window.dragMultiple.stop()

                $(document.body).removeClass("drag-active")

                sprint = null

                firstElement = if dragMultipleItems.length then dragMultipleItems[0] else item

                index = $(firstElement).index()
                if index == oldIndex
                    return

                if dragMultipleItems.length
                    usList = _.map dragMultipleItems, (item) ->
                        return item = $(item).scope().us
                else if $(item).scope()
                    usList = [$(item).scope().us]
                
                $scope.$applyAsync () =>
                    $scope.ctrl.moveUs("sprint:us:move", usList, index, previousUs, nextUs)

            scroll = autoScroll([window], {
                margin: 20,
                pixels: 30,
                scrollWhenOutside: true,
                autoScroll: () ->
                    return this.down && drake.dragging
            })

            $scope.$on "$destroy", ->
                $el.off()
                drake.destroy()

    return {link: link}


module.directive("tgTaskboardUsSortable", TaskboardUsSortableDirective)
