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
# File: modules/kanban/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy

module = angular.module("taigaKanban")

#############################################################################
## Kanban Controller
#############################################################################

class KanbanController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location) ->
        _.bindAll(@)

        @scope.sectionName = "Kanban"

        promise = @.loadInitialData()
        promise.then null, =>
            console.log "FAIL"

        # @scope.$on("usform:bulk:success", @.loadUserstories)
        # @scope.$on("sprintform:create:success", @.loadSprints)
        # @scope.$on("sprintform:create:success", @.loadProjectStats)
        # @scope.$on("sprintform:remove:success", @.loadSprints)
        # @scope.$on("sprintform:remove:success", @.loadProjectStats)
        # @scope.$on("usform:new:success", @.loadUserstories)
        # @scope.$on("usform:edit:success", @.loadUserstories)
        # @scope.$on("sprint:us:move", @.moveUs)
        # @scope.$on("sprint:us:moved", @.loadSprints)
        # @scope.$on("sprint:us:moved", @.loadProjectStats)

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @scope.stats = stats
            completedPercentage = Math.round(100 * stats.closed_points / stats.total_points)
            @scope.stats.completedPercentage = "#{completedPercentage}%"
            return stats

    loadUserstories: ->
        return @rs.userstories.listUnassigned(@scope.projectId).then (userstories) =>
            @scope.userstories = userstories

            @scope.usByStatus = _.groupBy(userstories, "status")

            for status in @scope.usStatusList
                if not @scope.usByStatus[status.id]?
                    @scope.usByStatus[status.id] = []

            # The broadcast must be executed when the DOM has been fully reloaded.
            # We can't assure when this exactly happens so we need a defer
            scopeDefer @scope, =>
                @scope.$broadcast("userstories:loaded")

            return userstories

    loadKanban: ->
        return @q.all([
            @.loadProjectStats(),
            @.loadUserstories()
        ])

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.points = _.sortBy(project.points, "order")
            @scope.pointsById = groupBy(project.points, (x) -> x.id)
            @scope.usStatusById = groupBy(project.us_statuses, (x) -> x.id)
            @scope.usStatusList = _.sortBy(project.us_statuses, "id")
            return project

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadKanban())

    prepareBulkUpdateData: (uses) ->
         return _.map(uses, (x) -> [x.id, x.order])

    resortUserStories: (uses) ->
        items = []
        for item, index in uses
            item.order = index
            if item.isModified()
                items.push(item)

        return items

    moveUs: (ctx, us, newUsIndex, newSprintId) ->
        oldSprintId = us.milestone

        # In the same sprint or in the backlog
        if newSprintId == oldSprintId
            items = null
            userstories = null

            if newSprintId == null
                userstories = @scope.userstories
            else
                userstories = @scope.sprintsById[newSprintId].user_stories

            @scope.$apply ->
                r = userstories.indexOf(us)
                userstories.splice(r, 1)
                userstories.splice(newUsIndex, 0, us)

            # Rehash userstories order field
            items = @.resortUserStories(userstories)
            data = @.prepareBulkUpdateData(items)

            # Persist in bulk all affected
            # userstories with order change
            promise = @rs.userstories.bulkUpdateOrder(us.project, data).then =>
                @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

            promise.then null, ->
                console.log "FAIL"

            return promise

        # From sprint to backlog
        if newSprintId == null
            us.milestone = null

            @scope.$apply =>
                # Add new us to backlog userstories list
                @scope.userstories.splice(newUsIndex, 0, us)
                @scope.visibleUserstories.splice(newUsIndex, 0, us)

                # Execute the prefiltering of user stories
                @.filterVisibleUserstories()

                # Remove the us from the sprint list.
                sprint = @scope.sprintsById[oldSprintId]
                r = sprint.user_stories.indexOf(us)
                sprint.user_stories.splice(r, 1)

            # Persist the milestone change of userstory
            promise = @repo.save(us)

            # Rehash userstories order field
            # and persist in bulk all changes.
            promise = promise.then =>
                items = @.resortUserStories(@scope.userstories)
                data = @.prepareBulkUpdateData(items)
                promise = @rs.userstories.bulkUpdateOrder(us.project, data).then =>
                    @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

            promise.then null, ->
                # TODO
                console.log "FAIL"

            return promise

        # From backlog to sprint
        newSprint = @scope.sprintsById[newSprintId]
        if us.milestone == null
            us.milestone = newSprintId

            @scope.$apply =>
                # Add moving us to sprint user stories list
                newSprint.user_stories.splice(newUsIndex, 0, us)

                # Remove moving us from backlog userstories lists.
                r = @scope.visibleUserstories.indexOf(us)
                @scope.visibleUserstories.splice(r, 1)
                r = @scope.userstories.indexOf(us)
                @scope.userstories.splice(r, 1)

        # From sprint to sprint
        else
            us.milestone = newSprintId

            @scope.$apply =>
                # Add new us to backlog userstories list
                newSprint.user_stories.splice(newUsIndex, 0, us)

                # Remove the us from the sprint list.
                oldSprint = @scope.sprintsById[oldSprintId]
                r = oldSprint.user_stories.indexOf(us)
                oldSprint.user_stories.splice(r, 1)

        # Persist the milestone change of userstory
        promise = @repo.save(us)

        # Rehash userstories order field
        # and persist in bulk all changes.
        promise = promise.then =>
            items = @.resortUserStories(newSprint.user_stories)
            data = @.prepareBulkUpdateData(items)
            promise = @rs.userstories.bulkUpdateOrder(us.project, data).then =>
                @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

        promise.then null, ->
            # TODO
            console.log "FAIL"

        return promise

    ## Template actions
    # editUserStory: (us) ->
    #     @rootscope.$broadcast("usform:edit", us)

    # deleteUserStory: (us) ->
    #     #TODO: i18n
    #     title = "Delete User Story"
    #     subtitle = us.subject

    #     @confirm.ask(title, subtitle).then =>
    #         # We modify the userstories in scope so the user doesn't see the removed US for a while
    #         @scope.userstories = _.without(@scope.userstories, us);
    #         @filterVisibleUserstories()
    #         @.repo.remove(us).then =>
    #             @.loadBacklog()

    # addNewUs: (type) ->
    #     switch type
    #         when "standard" then @rootscope.$broadcast("usform:new")
    #         when "bulk" then @rootscope.$broadcast("usform:bulk")


module.controller("KanbanController", KanbanController)

#############################################################################
## Kanban Directive
#############################################################################

KanbanDirective = ($repo, $rootscope) ->
    link = ($scope, $el, $attrs) ->
    return {link: link}


module.directive("tgKanban", ["$tgRepo", "$rootScope", KanbanDirective])
