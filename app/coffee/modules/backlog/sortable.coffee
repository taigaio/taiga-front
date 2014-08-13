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

deleteElement = (el) ->
    el.scope().$destroy()
    el.off()
    el.remove()


BacklogSortableDirective = ($repo, $rs, $rootscope) ->
    # Notes about jquery bug:
    # http://stackoverflow.com/questions/5791886/jquery-draggable-shows-
    # helper-in-wrong-place-when-scrolled-down-page

    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
            if project.my_permissions.indexOf("modify_us") > -1

                $el.sortable({
                    connectWith: ".sprint-table"
                    handle: ".icon-drag-v",
                    containment: ".wrapper"
                    dropOnEmpty: true
                    placeholder: "row us-item-row us-item-drag sortable-placeholder"
                    # With scroll activated, it has strange behavior
                    # with not full screen browser window.
                    scroll: false
                    # A consequence of length of backlog user story item
                    # the default tolerance ("intersection") not works properly.
                    tolerance: "pointer"
                    # Revert on backlog is disabled bacause it works bad. Something
                    # on the current taiga backlog structure or style makes jquery ui
                    # works unexpectly (in some circumstances calculates wrong
                    # position for revert).
                    revert: false
                })

                $el.on "sortreceive", (event, ui) ->
                    itemUs = ui.item.scope().us
                    itemIndex = ui.item.index()

                    deleteElement(ui.item)
                    $scope.$emit("sprint:us:move", itemUs, itemIndex, null)

                $el.on "sortstop", (event, ui) ->
                    # When parent not exists, do nothing
                    if ui.item.parent().length == 0
                        return

                    itemUs = ui.item.scope().us
                    itemIndex = ui.item.index()
                    $scope.$emit("sprint:us:move", itemUs, itemIndex, null)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

BacklogEmptySortableDirective = ($repo, $rs, $rootscope) ->
    # Notes about jquery bug:
    # http://stackoverflow.com/questions/5791886/jquery-draggable-shows-
    # helper-in-wrong-place-when-scrolled-down-page

    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
            if project.my_permissions.indexOf("modify_us") > -1
                $el.sortable({
                    dropOnEmpty: true
                })

                $el.on "sortreceive", (event, ui) ->
                    itemUs = ui.item.scope().us
                    itemIndex = ui.item.index()

                    deleteElement(ui.item)
                    $scope.$emit("sprint:us:move", itemUs, itemIndex, null)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


SprintSortableDirective = ($repo, $rs, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
            if project.my_permissions.indexOf("modify_us") > -1
                $el.sortable({
                    dropOnEmpty: true
                    connectWith: ".sprint-table,.backlog-table-body,.empty-backlog"
                })

                $el.on "sortreceive", (event, ui) ->
                    itemUs = ui.item.scope().us
                    itemIndex = ui.item.index()

                    deleteElement(ui.item)
                    $scope.$emit("sprint:us:move", itemUs, itemIndex, $scope.sprint.id)

                $el.on "sortstop", (event, ui) ->
                    # When parent not exists, do nothing
                    if ui.item.parent().length == 0
                        return

                    itemUs = ui.item.scope().us
                    itemIndex = ui.item.index()

                    $scope.$emit("sprint:us:move", itemUs, itemIndex, $scope.sprint.id)

    return {link:link}


module.directive("tgBacklogSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    BacklogSortableDirective
])

module.directive("tgBacklogEmptySortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    BacklogEmptySortableDirective
])

module.directive("tgSprintSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    SprintSortableDirective
])
