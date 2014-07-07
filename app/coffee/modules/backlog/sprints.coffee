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
# File: modules/backlog/sprints.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy

module = angular.module("taigaBacklog")

#############################################################################
## Sprint Directive
#############################################################################

BacklogSprintDirective = ($repo, $rootscope) ->

    #########################
    ## Common parts
    #########################

    linkCommon = ($scope, $el, $attrs, $ctrl) ->
        sprint = $scope.$eval($attrs.tgBacklogSprint)
        if $scope.$first
            $el.addClass("sprint-current")
            $el.find(".sprint-table").addClass('open')

        else if sprint.closed
            $el.addClass("sprint-closed")

        else if not $scope.$first and not sprint.closed
            $el.addClass("sprint-old-open")

        # Update progress bars
        progressPercentage = Math.round(100 * (sprint.closed_points / sprint.total_points))
        $el.find(".current-progress").css("width", "#{progressPercentage}%")

        $el.find(".sprint-table").disableSelection()

        # Event Handlers
        $el.on "click", ".sprint-name > .icon-arrow-up", (event) ->
            target = $(event.currentTarget)
            target.toggleClass('active')
            $el.find(".sprint-table").toggleClass('open')

        $el.on "click", ".sprint-name > .icon-edit", (event) ->
            $rootscope.$broadcast("sprintform:edit", sprint)

    #########################
    ## Drag & Drop Link
    #########################

    # linkSortable = ($scope, $el, $attrs, $ctrl) ->
    #     resortAndSave = ->
    #         toSave = []
    #         for item, i in $scope.sprint.user_stories
    #             if item.order == i
    #                 continue
    #             item.order = i

    #         toSave = _.filter($scope.sprint.user_stories, (x) -> x.isModified())
    #         $repo.saveAll(toSave).then ->
    #             console.log "FINISHED", arguments

    #     onUpdateItem = (event) ->
    #         item = angular.element(event.item)
    #         itemScope = item.scope()

    #         ids = _.map($scope.sprint.user_stories, {"id": itemScope.us.id})
    #         index = ids.indexOf(itemScope.us.id)

    #         $scope.sprint.user_stories.splice(index, 1)
    #         $scope.sprint.user_stories.splice(item.index(), 0, itemScope.us)
    #         resortAndSave()

    #     onAddItem = (event) ->
    #         item = angular.element(event.item)
    #         itemScope = item.scope()
    #         itemIndex = item.index()

    #         itemScope.us.milestone = $scope.sprint.id
    #         userstories = $scope.sprint.user_stories
    #         userstories.splice(itemIndex, 0, itemScope.us)

    #         item.remove()
    #         item.off()

    #         $scope.$apply()
    #         resortAndSave()

    #     onRemoveItem = (event) ->
    #         item = angular.element(event.item)
    #         itemScope = item.scope()

    #         ids = _.map($scope.sprint.user_stories, "id")
    #         index = ids.indexOf(itemScope.us.id)

    #         if index != -1
    #             userstories = $scope.sprint.user_stories
    #             userstories.splice(index, 1)

    #         item.off()
    #         itemScope.$destroy()

    #     dom = $el.find(".sprint-table")

    #     sortable = new Sortable(dom[0], {
    #         group: "backlog",
    #         selector: ".milestone-us-item-row",
    #         onUpdate: onUpdateItem,
    #         onAdd: onAddItem,
    #         onRemove: onRemoveItem,
    #     })

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.closest("div.wrapper").controller()
        linkCommon($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgBacklogSprint", ["$tgRepo", "$rootScope", BacklogSprintDirective])
