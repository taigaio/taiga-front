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

    resort = (uses) ->
        items = []
        for item, index in uses
            item.order = index
            if item.isModified()
                items.push(item)

        return items

    prepareBulkUpdateData = (uses) ->
        return _.map(uses, (x) -> [x.id, x.order])

    linkSortable = ($scope, $el, $attrs, $ctrl) ->
        # State
        oldParentScope = null
        newParentScope = null
        itemEl = null
        tdom = $el

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
                itemUs.milestone = null

                # Completelly remove item and its scope from dom
                itemEl.scope().$destroy()
                itemEl.off()
                itemEl.remove()

                $scope.$apply ->
                    # Add new us to backlog userstories list
                    newParentScope.userstories.splice(itemIndex, 0, itemUs)
                    newParentScope.visibleUserstories.splice(itemIndex, 0, itemUs)

                    # Execute the prefiltering of user stories
                    $ctrl.filterVisibleUserstories()

                    # Remove the us from the sprint list.
                    r = oldParentScope.sprint.user_stories.indexOf(itemUs)
                    oldParentScope.sprint.user_stories.splice(r, 1)

                # Persist the milestone change of userstory
                promise = $repo.save(itemUs)

                # Rehash userstories order field
                # and persist in bulk all changes.
                promise = promise.then ->
                    projectId = $scope.projectId

                    items = resort(newParentScope.userstories)
                    data = prepareBulkUpdateData(items)

                    return $rs.userstories.bulkUpdateOrder(projectId, data)

                promise.then null, ->
                    # TODO
                    console.log "FAIL"

            else if itemEl.is(".us-item-row") and parentEl.is(".sprint-table")

                # Completelly remove item and its scope from dom
                itemEl.scope().$destroy()
                itemEl.off()
                itemEl.remove()

                itemUs.milestone = newParentScope.sprint.id

                $scope.$apply ->
                    # Add moving us to sprint user stories list
                    newParentScope.sprint.user_stories.splice(itemIndex, 0, itemUs)

                    # Remove moving us from backlog userstories lists.
                    r = oldParentScope.visibleUserstories.indexOf(itemUs)
                    oldParentScope.visibleUserstories.splice(r, 1)
                    r = oldParentScope.userstories.indexOf(itemUs)
                    oldParentScope.userstories.splice(r, 1)

                # Persist the milestone change of userstory
                promise = $repo.save(itemUs)

                # Rehash userstories order field
                # and persist in bulk all changes.
                promise = promise.then ->
                    projectId = $scope.projectId
                    items = resort(newParentScope.sprint.user_stories)
                    data = prepareBulkUpdateData(items)
                    return $rs.userstories.bulkUpdateOrder(projectId, data)

                # TODO: handle properly the error
                promise.then null, ->
                    console.log "FAIL"

            else if parentEl.is(".sprint-table") and newParentScope.sprint.id != oldParentScope.sprint.id
                itemUs.milestone = newParentScope.sprint.id

                # Completelly remove item and its scope from dom
                itemEl.scope().$destroy()
                itemEl.off()
                itemEl.remove()

                $scope.$apply ->
                    # Add new us to backlog userstories list
                    newParentScope.sprint.user_stories.splice(itemIndex, 0, itemUs)

                    # Remove the us from the sprint list.
                    r = oldParentScope.sprint.user_stories.indexOf(itemUs)
                    oldParentScope.sprint.user_stories.splice(r, 1)

                # Persist the milestone change of userstory
                promise = $repo.save(itemUs)

                # Rehash userstories order field
                # and persist in bulk all changes.
                promise = promise.then ->
                    projectId = $scope.projectId

                    items = resort(newParentScope.sprint.user_stories)
                    data = prepareBulkUpdateData(items)
                    return $rs.userstories.bulkUpdateOrder(projectId, data)

                promise.then null, ->
                    # TODO
                    console.log "FAIL"

            else
                items = null
                userstories = null

                if parentEl.is(".backlog-table-body")
                    userstories = newParentScope.userstories
                else
                    userstories = newParentScope.sprint.user_stories

                $scope.$apply ->
                    r = userstories.indexOf(itemUs)
                    userstories.splice(r, 1)
                    userstories.splice(itemIndex, 0, itemUs)

                # Rehash userstories order field
                items = resort(userstories)
                data = prepareBulkUpdateData(items)

                # Persist in bulk all affected
                # userstories with order change
                promise = $rs.userstories.bulkUpdateOrder($scope.projectId, data)
                promise.then null, ->
                    console.log "FAIL"

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
