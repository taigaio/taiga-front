###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
            if not (project.my_permissions.indexOf("modify_us") > -1)
                return

            initIsBacklog = false

            drake = dragula([$el[0], $('.js-empty-backlog')[0]], {
                copySortSource: false,
                copy: false,
                isContainer: (el) -> return el.classList.contains('sprint-table'),
                moves: (item) ->
                    if !$(item).hasClass('row')
                        return false

                    return true
            })

            drake.on 'drag', (item, container) ->
                # it doesn't move is the filter is open
                parent = $(item).parent()
                initIsBacklog = parent.hasClass('backlog-table-body')

                $(document.body).addClass("drag-active")

                isChecked = $(item).find("input[type='checkbox']").is(":checked")

                window.dragMultiple.start(item, container)

            drake.on 'cloned', (item) ->
                $(item).addClass('multiple-drag-mirror')

            drake.on 'dragend', (item) ->
                parent = $(item).parent()

                $('.doom-line').remove()

                parent = $(item).parent()

                isBacklog = parent.hasClass('backlog-table-body') || parent.hasClass('js-empty-backlog')

                if initIsBacklog || isBacklog
                    sameContainer = (initIsBacklog == isBacklog)
                else
                    sameContainer = $(item).scope().sprint.id == parent.scope().sprint.id

                dragMultipleItems = window.dragMultiple.stop()

                $(document.body).removeClass("drag-active")

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
                        usList = [$(item).scope().us]

                $scope.$emit("sprint:us:move", usList, index, sprint)

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
