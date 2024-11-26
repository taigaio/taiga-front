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

deleteElement = (el) ->
    $(el).scope().$destroy()
    $(el).off()
    $(el).remove()

BacklogSortableDirective = () ->
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
                isContainer: (el) -> return el.classList.contains('sprint-table'),
                moves: (item) ->
                    if !$(item).hasClass('row')
                        return false

                    return true
            })

            drake.on 'drop', (item, target, source, sibling) ->
                previousUs = null
                nextUs = null

                prev = $(item).prevAll('.row:not(.gu-transit)')
                next = $(item).nextAll('.row:not(.gu-transit)')

                previousUs = null
                if prev.length && prev[0].dataset.id
                    previousUs = Number(prev[0].dataset.id)

                nextUs = null
                if !previousUs && next.length && next[0].dataset.id
                    nextUs = Number(next[0].dataset.id)

            drake.on 'drag', (item, container) ->
                if $scope.ctrl.displayVelocity
                    $scope.ctrl.toggleVelocityForecasting()

                # it doesn't move is the filter is open
                parent = $(item).parent()
                initIsBacklog = parent.hasClass('backlog-table-body')

                $(document.body).addClass("drag-active")

                isChecked = $(item).find("input[type='checkbox']").is(":checked")

                window.dragMultiple.start(item, container)

                dragMultipleItems = window.dragMultiple.getElements()

                firstElement = if dragMultipleItems.length then dragMultipleItems[0] else item

                parentEl = item.parentNode
                oldIndex = $(parentEl).find('tg-card').index(firstElement)

                if initIsBacklog
                    oldIndex = $(firstElement).index(".backlog-table-body .row")
                else
                    oldIndex = $(firstElement).index()

            drake.on 'cloned', (item) ->
                $(item).addClass('multiple-drag-mirror')

            drake.on 'dragend', (item) ->
                $('.doom-line').remove()

                parent = $(item).parent()

                isBacklog = parent.hasClass('backlog-table-body') || parent.hasClass('js-empty-backlog')

                if initIsBacklog || isBacklog
                    sameContainer = (initIsBacklog == isBacklog)
                else
                    sameContainer = parent && $(item).scope().sprint.id == parent.scope().sprint.id

                dragMultipleItems = window.dragMultiple.stop()

                $(document.body).removeClass("drag-active")

                sprint = null

                firstElement = if dragMultipleItems.length then dragMultipleItems[0] else item

                if isBacklog
                    index = $(firstElement).index(".backlog-table-body .row")
                else
                    index = $(firstElement).index()
                    sprint = parent.scope()?.sprint.id

                if index == oldIndex && sameContainer
                    return

                if !sameContainer
                    if dragMultipleItems.length
                        usList = _.map dragMultipleItems, (item) ->
                            return item = $(item).scope().us
                    else if $(item).scope()
                        usList = [$(item).scope().us]

                    if (dragMultipleItems.length)
                        _.each dragMultipleItems, (item) ->
                            deleteElement(item)
                    else
                        deleteElement(item)
                else
                    if dragMultipleItems.length
                        usList = _.map dragMultipleItems, (item) ->
                            return item = $(item).scope().us
                    else if $(item).scope()
                        usList = [$(item).scope().us]

                $scope.$applyAsync () =>
                    $scope.ctrl.moveUs("sprint:us:move", usList, index, sprint, previousUs, nextUs)

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

module.directive("tgBacklogSortable", BacklogSortableDirective)
