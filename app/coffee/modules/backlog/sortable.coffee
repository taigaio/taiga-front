###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/backlog/sortable.coffee
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

deleteElement = (el) ->
    $(el).scope().$destroy()
    $(el).off()
    $(el).remove()

BacklogSortableDirective = ($repo, $rs, $rootscope, $tgConfirm, $translate) ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
            if not (project.my_permissions.indexOf("modify_us") > -1)
                return

            initIsBacklog = false

            filterError = ->
                text = $translate.instant("BACKLOG.SORTABLE_FILTER_ERROR")
                $tgConfirm.notify("error", text)

            drake = dragula([$el[0], $('.empty-backlog')[0]], {
                copySortSource: false,
                copy: false,
                isContainer: (el) -> return el.classList.contains('sprint-table'),
                moves: (item) ->
                    if !$(item).hasClass('row')
                        return false

                    # it doesn't move is the filter is open
                    parent = $(item).parent()
                    initIsBacklog = parent.hasClass('backlog-table-body')

                    if initIsBacklog && $el.hasClass("active-filters")
                        filterError()
                        return false

                    return true
            })

            drake.on 'drag', (item, container) ->
                parent = $(item).parent()
                initIsBacklog = parent.hasClass('backlog-table-body')

                $(document.body).addClass("drag-active")

                isChecked = $(item).find("input[type='checkbox']").is(":checked")

                window.dragMultiple.start(item, container)

            drake.on 'cloned', (item) ->
                $(item).addClass('backlog-us-mirror')

            drake.on 'dragend', (item) ->
                $('.doom-line').remove()

                parent = $(item).parent()
                isBacklog = parent.hasClass('backlog-table-body') || parent.hasClass('empty-backlog')

                sameContainer = (initIsBacklog == isBacklog)

                dragMultipleItems = window.dragMultiple.stop()

                $(document.body).removeClass("drag-active")

                items = $(item).parent().find('.row')

                sprint = null

                firstElement = if dragMultipleItems.length then dragMultipleItems[0] else item

                if isBacklog
                    index = $(firstElement).index(".backlog-table-body .row")
                else
                    index = $(firstElement).index()
                    sprint = parent.scope().sprint.id

                if !sameContainer
                    if dragMultipleItems.length
                        usList = _.map dragMultipleItems, (item) ->
                            return item = $(item).scope().us
                    else
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
                    else
                        usList = _.map items, (item) ->
                            item = $(item)
                            itemUs = item.scope().us

                            return itemUs

                $scope.$emit("sprint:us:move", usList, index, sprint)

            scroll = autoScroll([window], {
                margin: 20,
                pixels: 30,
                scrollWhenOutside: true,
                autoScroll: () ->
                    return this.down && drake.dragging;
            })

            $scope.$on "$destroy", ->
                $el.off()
                drake.destroy()

    return {link: link}

module.directive("tgBacklogSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "$tgConfirm",
    "$translate",
    BacklogSortableDirective
])
