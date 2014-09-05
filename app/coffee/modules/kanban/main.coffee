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
timeout = @.taiga.timeout

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
        "$tgLocation",
        "$appTitle",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @appTitle, tgLoader) ->
        _.bindAll(@)
        @scope.sectionName = "Kanban"

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set("Kanban - " + @scope.project.name)
            tgLoader.pageLoaded()

        # On Error
        promise.then null, (xhr) =>
            if xhr and xhr.status == 404
                @location.path("/not-found")
                @location.replace()
            return @q.reject(xhr)

        @scope.$on("usform:new:success", @.loadUserstories)
        @scope.$on("usform:bulk:success", @.loadUserstories)
        @scope.$on("usform:edit:success", @.loadUserstories)
        @scope.$on("assigned-to:added", @.onAssignedToChanged)
        @scope.$on("kanban:us:move", @.moveUs)

    # Template actions

    addNewUs: (type, statusId) ->
        switch type
            when "standard" then @rootscope.$broadcast("usform:new", @scope.projectId, statusId, @scope.usStatusList)
            when "bulk" then @rootscope.$broadcast("usform:bulk", @scope.projectId, statusId)

    changeUsAssignedTo: (us) ->
        @rootscope.$broadcast("assigned-to:add", us)

    # Scope Events Handlers

    onAssignedToChanged: (ctx, userid, us) ->
        us.assigned_to = userid

        promise = @repo.save(us)
        promise.then null, ->
            console.log "FAIL" # TODO

    # Load data methods

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @scope.stats = stats

            if stats.total_points
                completedPercentage = Math.round(100 * stats.closed_points / stats.total_points)
            else
                completedPercentage = 0

            @scope.stats.completedPercentage = "#{completedPercentage}%"
            return stats

    refreshTagsColors: ->
        return @rs.projects.tagsColors(@scope.projectId).then (tags_colors) =>
            @scope.project.tags_colors = tags_colors

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
            @.refreshTagsColors(),
            @.loadProjectStats(),
            @.loadUserstories()
        ])

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.points = _.sortBy(project.points, "order")
            @scope.pointsById = groupBy(project.points, (x) -> x.id)
            @scope.usStatusById = groupBy(project.us_statuses, (x) -> x.id)
            @scope.usStatusList = _.sortBy(project.us_statuses, "order")
            return project

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadKanban())
                      .then(=> @scope.$broadcast("redraw:wip"))

    prepareBulkUpdateData: (uses) ->
        return _.map(uses, (x) -> {"us_id": x.id, "order": x.order})

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
        else if not @scope.project.is_backlog_activated
            current_position = @scope.usByStatus[us.status].indexOf(us)
            new_position = index

            @scope.usByStatus[us.status].splice(current_position, 1)
            @scope.usByStatus[us.status].splice(new_position, 0, us)

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


module.controller("KanbanController", KanbanController)

#############################################################################
## Kanban Directive
#############################################################################

KanbanDirective = ($repo, $rootscope) ->
    link = ($scope, $el, $attrs) ->

        tableBodyDom = $el.find(".kanban-table-body")
        tableBodyDom.on "scroll", (event) ->
            target = angular.element(event.currentTarget)
            tableHeaderDom = $el.find(".kanban-table-header .kanban-table-inner")
            tableHeaderDom.css("left", -1 * target.scrollLeft())

    return {link: link}

module.directive("tgKanban", ["$tgRepo", "$rootScope", KanbanDirective])


#############################################################################
## Kanban Row Size Fixer Directive
#############################################################################

KanbanRowSizeFixer = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "usStatusList", (statuses) ->
            itemSize = 310
            size = (statuses.length * itemSize) - 10
            $el.css("width", "#{size}px")

    return {link: link}

module.directive("tgKanbanRowSizeFixer", KanbanRowSizeFixer)


#############################################################################
## Kaban User Story Directive
#############################################################################

KanbanUserstoryDirective = ($rootscope) ->
    link = ($scope, $el, $attrs, $model) ->
        $el.find(".icon-edit").on "click", (event) ->
            if $el.find('.icon-edit').hasClass('noclick')
                return
            $scope.$apply ->
                $rootscope.$broadcast("usform:edit", $model.$modelValue)
        if $scope.us.is_blocked
            $el.addClass('blocked')
        $el.disableSelection()

    return {
        templateUrl: "/partials/views/components/kanban-task.html"
        link: link
        require: "ngModel"
    }


module.directive("tgKanbanUserstory", ["$rootScope", KanbanUserstoryDirective])


#############################################################################
## Kaban WIP Limit Directive
#############################################################################

KanbanWipLimitDirective = ->
    link = ($scope, $el, $attrs) ->
        $el.disableSelection()

        redrawWipLimit = ->
            $el.find('.kanban-wip-limit').remove()
            timeout 200, ->
                element = $el.find('.kanban-task')[$scope.status.wip_limit]
                if element
                        angular.element(element).before("<div class='kanban-wip-limit'></div>")

        $scope.$on "redraw:wip", redrawWipLimit
        $scope.$on "kanban:us:move", redrawWipLimit
        $scope.$on "usform:new:success", redrawWipLimit
        $scope.$on "usform:bulk:success", redrawWipLimit

    return {link: link}

module.directive("tgKanbanWipLimit", KanbanWipLimitDirective)


#############################################################################
## Kanban User Directive
#############################################################################

KanbanUserDirective = ($log) ->
    template = _.template("""
    <figure class="avatar">
        <a href="#" title="Assign User Story" <% if (!clickable) {%>class="not-clickable"<% } %>>
            <img src="<%= imgurl %>" alt="<%- name %>" class="avatar">
        </a>
    </figure>
    """) # TODO: i18n

    clickable = false

    link = ($scope, $el, $attrs, $model) ->
        if not $attrs.tgKanbanUserAvatar
            return $log.error "KanbanUserDirective: no attr is defined"

        wtid = $scope.$watch $attrs.tgKanbanUserAvatar, (v) ->
            if not $scope.usersById?
                $log.error "KanbanUserDirective requires userById set in scope."
                wtid()
            else
                user = $scope.usersById[v]
                render(user)

        render = (user) ->
            if user is undefined
                ctx = {name: "Unassigned", imgurl: "/images/unnamed.png", clickable: clickable}
            else
                ctx = {name: user.full_name_display, imgurl: user.photo, clickable: clickable}

            html = template(ctx)
            $el.html(html)
            username_label = $el.parent().find("a.task-assigned")
            username_label.html(ctx.name)
            username_label.on "click", (event) ->
                if $el.find('a').hasClass('noclick')
                    return

                us = $model.$modelValue
                $ctrl = $el.controller()
                $ctrl.changeUsAssignedTo(us)

        bindOnce $scope, "project", (project) ->
            if project.my_permissions.indexOf("modify_us") > -1
                clickable = true
                $el.on "click", (event) =>
                    if $el.find('a').hasClass('noclick')
                        return

                    us = $model.$modelValue
                    $ctrl = $el.controller()
                    $ctrl.changeUsAssignedTo(us)

    return {link: link, require:"ngModel"}


module.directive("tgKanbanUserAvatar", ["$log", KanbanUserDirective])
