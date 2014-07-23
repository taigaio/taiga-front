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
        @scope.$on("usform:new:success", @.onNewUserstory)
        @scope.$on("usform:edit:success", @.onUserstoryEdited)
        @scope.$on("kanban:us:move", @.moveUs)
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

    moveUs: (ctx, us, statusId, index) ->
        if us.status != statusId
            # Remove us from old status column
            r = @scope.usByStatus[us.status].indexOf(us)
            @scope.usByStatus[us.status].splice(r, 1)

            # Add us to new status column.
            @scope.usByStatus[statusId].splice(index, 0, us)

            us.status = statusId

        # Persist the userstory
        promise = @repo.save(us)

        # Rehash userstories order field
        # and persist in bulk all changes.
        promise = promise.then =>
            items = @.resortUserStories(@scope.usByStatus[statusId])
            data = @.prepareBulkUpdateData(items)

            return @rs.userstories.bulkUpdateOrder(us.project, data).then =>
                # @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)
                return items

        promise.then null, ->
            # TODO
            console.log "FAIL"

        return promise

    ## Template actions
    editUserStory: (us) ->
        @rootscope.$broadcast("usform:edit", us)

    addNewUs: (type, statusId) ->
        switch type
            when "standard" then @rootscope.$broadcast("usform:new", statusId)
            when "bulk" then @rootscope.$broadcast("usform:bulk", statusId)

    changeUsAssignedTo: (us) ->
        @rootscope.$broadcast("assigned-to:add", us)

    # Scope Events Handlers
    onNewUserstory: (ctx, us) ->
        @scope.usByStatus[us.status].splice(0, 0, us)

    onUserstoryEdited: (ctx, us) ->
        @.loadUserstories()


module.controller("KanbanController", KanbanController)

#############################################################################
## Kanban Directive
#############################################################################

KanbanDirective = ($repo, $rootscope) ->
    link = ($scope, $el, $attrs) ->
    return {link: link}


module.directive("tgKanban", ["$tgRepo", "$rootScope", KanbanDirective])


#############################################################################
## Taskboard Task Directive
#############################################################################

KanbanUserstoryDirective = ->
    link = ($scope, $el, $attrs, $model) ->
        $el.disableSelection()

    return {
        templateUrl: "/partials/views/components/kanban-task.html"
        link:link
        require: "ngModel"
    }


module.directive("tgKanbanUserstory", KanbanUserstoryDirective)


#############################################################################
## Kanban User Directive
#############################################################################

KanbanUserDirective = ($log) ->
    template = _.template("""
    <figure class="avatar">
        <a href="#" title="<%- name %>">
            <img src="<%= imgurl %>" alt="<%- name %>" class="avatar">
            <span class="assigned-to">
                <span><%- name %></span>
            </span>
        </a>
    </figure>
    """)

    uniqueId = _.uniqueId("user_photo")

    link = ($scope, $el, $attrs) ->
        if not $attrs.model?
            return $log.error "KanbanUserDirective: no model attr is defined"

        wtid = $scope.$watch $attrs.model, (v) ->
            if not $scope.usersById?
                $log.error "KanbanUserDirective requires userById set in scope."
                wtid()
            else
                user = $scope.usersById[v]
                render(user)

        render = (user) ->
            if user is undefined
                ctx = {name: "Unassigned", imgurl: "http://thecodeplayer.com/u/uifaces/12.jpg"}
            else
                ctx = {name: user.full_name_display, imgurl: user.photo}

            html = template(ctx)
            $el.off(".#{uniqueId}")
            $el.html(html)
            $el.on "click.#{uniqueId}", "figure.avatar > a", (event) ->
                if not $attrs.click?
                    return $log.error "KanbanUserDirective: No click attr is defined."

                $scope.$apply ->
                    $scope.$eval($attrs.click)

    return {
        link: link
        restrict: "AE"
    }


module.directive("tgKanbanUserAvatar", ["$log", KanbanUserDirective])
