###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

            initialContainer = null

            drake.on 'shadow', (item) ->
                $(item).removeClass('folded-dragging')

            drake.on 'over', (item, container) ->
                if !initialContainer
                    initialContainer = container
                else if container != initialContainer
                    $(container).addClass('target-drop')

            drake.on 'out', (item, container) ->
                if container != initialContainer
                    $(container).removeClass('target-drop')

            drake.on 'drag', (item) ->
                oldParentScope = $(item).parent().scope()

                if $(item).width() == 30
                    $(item).addClass('folded-dragging')

                if $el.hasClass("active-filters")
                    filterError()

                    setTimeout (() ->
                        drake.cancel(true)
                    ), 0

                    return false

            drake.on 'dragend', (item) ->
                parentEl = $(item).parent()
                itemEl = $(item)
                itemTask = $scope.taskMap.get(Number(item.dataset.id))
                itemIndex = itemEl.index()
                newParentScope = parentEl.scope()

                oldUsId = if oldParentScope.us then oldParentScope.us.id else null
                oldStatusId = oldParentScope.st.id
                newUsId = if newParentScope.us then newParentScope.us.id else null
                newStatusId = newParentScope.st.id

                if initialContainer != parentEl
                    $(parentEl).addClass('new')

                    $(parentEl).one 'animationend', ()  ->
                        $(parentEl).removeClass('new')

                if newStatusId != oldStatusId or newUsId != oldUsId
                    deleteElement(itemEl)

                $scope.$apply ->
                    # prevent fold/unfold animation
                    tableBody = $('.taskboard-table-body')

                    tableBody.addClass('moving')

                    # wait animation end
                    setTimeout () ->
                        tableBody.removeClass('moving')
                    , 1000

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
