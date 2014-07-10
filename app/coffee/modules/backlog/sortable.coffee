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

BacklogSortableDirective = ($repo, $rs, $rootscope) ->

    #########################
    ## Drag & Drop Link
    #########################
    # http://stackoverflow.com/questions/5791886/jquery-draggable-shows-
    # helper-in-wrong-place-when-scrolled-down-page

    linkSortable = ($scope, $el, $attrs, $ctrl) ->
        # State
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
            # handle: ".icon-drag-v",
            items: "div.sprint-table > div.row, .backlog-table-body > div.row"
        })

        tdom.on "sortstop", (event, ui) ->
            # Common state for stop event handler
            parentEl = ui.item.parent()
            itemEl = ui.item
            itemUs = itemEl.scope().us
            itemIndex = itemEl.index()
            newParentScope = parentEl.scope()

            if itemEl.is(".milestone-us-item-row") and parentEl.is(".backlog-table-body")
                deleteElement(itemEl)
                $scope.$broadcast("sprint:us:move", itemUs, itemIndex, null)

            else if itemEl.is(".us-item-row") and parentEl.is(".sprint-table")
                deleteElement(itemEl)
                $scope.$broadcast("sprint:us:move", itemUs, itemIndex, newParentScope.sprint.id)

            else if parentEl.is(".sprint-table") and newParentScope.sprint.id != oldParentScope.sprint.id
                deleteElement(itemEl)
                $scope.$broadcast("sprint:us:move", itemUs, itemIndex, newParentScope.sprint.id)

            else
                $scope.$broadcast("sprint:us:move", itemUs, itemIndex, itemUs.milestone)

        tdom.on "sortstart", (event, ui) ->
            oldParentScope = ui.item.parent().scope()

        tdom.on "sort", (event, ui) ->
            ui.helper.css("background-color", "#ddd")

        tdom.on "sortbeforestop", (event, ui) ->
            ui.helper.css("background-color", "transparent")

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSortable($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgBacklogSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    BacklogSortableDirective
])
