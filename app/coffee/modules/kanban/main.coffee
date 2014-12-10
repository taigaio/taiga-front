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
bindMethods = @.taiga.bindMethods

module = angular.module("taigaKanban")

# Vars

defaultViewMode = "maximized"
defaultViewModes = {
    maximized: {
        cardClass: "kanban-task-maximized"
    }
    minimized: {
        cardClass: "kanban-task-minimized"
    }
}


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
        "$tgNavUrls",
        "$tgEvents",
        "$tgAnalytics",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @appTitle, @navUrls, @events, @analytics, tgLoader) ->

        bindMethods(@)

        @scope.sectionName = "Kanban"
        @scope.statusViewModes = {}
        @.initializeEventHandlers()
        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set("Kanban - " + @scope.project.name)
            tgLoader.pageLoaded()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    initializeEventHandlers: ->
        @scope.$on "usform:new:success", =>
            @.loadUserstories()
            @.refreshTagsColors()
            @analytics.trackEvent("userstory", "create", "create userstory on kanban", 1)

        @scope.$on "usform:bulk:success", =>
            @.loadUserstories()
            @analytics.trackEvent("userstory", "create", "bulk create userstory on kanban", 1)

        @scope.$on "usform:edit:success", =>
            @.loadUserstories()
            @.refreshTagsColors()

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
        return @rs.userstories.listAll(@scope.projectId).then (userstories) =>
            @scope.userstories = userstories
            @scope.usByStatus = _.groupBy(userstories, "status")

            for status in @scope.usStatusList
                if not @scope.usByStatus[status.id]?
                    @scope.usByStatus[status.id] = []
                @scope.usByStatus[status.id] = _.sortBy(@scope.usByStatus[status.id], "kanban_order")

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
            @scope.points = _.sortBy(project.points, "order")
            @scope.pointsById = groupBy(project.points, (x) -> x.id)
            @scope.usStatusById = groupBy(project.us_statuses, (x) -> x.id)
            @scope.usStatusList = _.sortBy(project.us_statuses, "order")

            @.generateStatusViewModes()

            @scope.$emit("project:loaded", project)
            return project

    initializeSubscription: ->
        routingKey1 = "changes.project.#{@scope.projectId}.userstories"
        @events.subscribe @scope, routingKey1, (message) =>
            @.loadUserstories()

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            @.initializeSubscription()
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadKanban())
                      .then(=> @scope.$broadcast("redraw:wip"))

    ## View Mode methods

    generateStatusViewModes: ->
        storedStatusViewModes = @rs.kanban.getStatusViewModes(@scope.projectId)

        @scope.statusViewModes = {}
        for status in @scope.usStatusList
            mode = storedStatusViewModes[status.id]
            @scope.statusViewModes[status.id] = if _.has(defaultViewModes, mode) then mode else defaultViewMode

        @.storeStatusViewModes()

    storeStatusViewModes: ->
        @rs.kanban.storeStatusViewModes(@scope.projectId, @scope.statusViewModes)

    updateStatusViewMode: (statusId, newViewMode) ->
        @scope.statusViewModes[statusId] = newViewMode
        @.storeStatusViewModes()

    getCardClass: (statusId)->
        mode = @scope.statusViewModes[statusId] or defaultViewMode
        return defaultViewModes[mode].cardClass or defaultViewModes[defaultViewMode].cardClass

    # Utils methods

    prepareBulkUpdateData: (uses, field="kanban_order") ->
        return _.map(uses, (x) -> {"us_id": x.id, "order": x[field]})

    resortUserStories: (uses) ->
        items = []
        for item, index in uses
            item.kanban_order = index
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
        else
            r = @scope.usByStatus[statusId].indexOf(us)
            @scope.usByStatus[statusId].splice(r, 1)
            @scope.usByStatus[statusId].splice(index, 0, us)

        itemsToSave = @.resortUserStories(@scope.usByStatus[statusId])
        @scope.usByStatus[statusId] = _.sortBy(@scope.usByStatus[statusId], "kanban_order")

        # Persist the userstory
        promise = @repo.save(us)

        # Rehash userstories order field
        # and persist in bulk all changes.
        promise = promise.then =>
            itemsToSave = _.reject(itemsToSave, {"id": us.id})
            data = @.prepareBulkUpdateData(itemsToSave)

            return @rs.userstories.bulkUpdateKanbanOrder(us.project, data).then =>
                return itemsToSave

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

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgKanban", ["$tgRepo", "$rootScope", KanbanDirective])


#############################################################################
## Kanban Column Height Fixer Directive
#############################################################################

KanbanColumnHeightFixerDirective = ->
    mainPadding = 32 # px
    scrollPadding = 0 # px

    renderSize = ($el) ->
        elementOffset = $el.parent().parent().offset().top
        windowHeight = angular.element(window).height()
        columnHeight = windowHeight - elementOffset - mainPadding - scrollPadding
        $el.css("height", "#{columnHeight}px")

    link = ($scope, $el, $attrs) ->
        timeout(500, -> renderSize($el))

        $scope.$on "resize", ->
            renderSize($el)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}


module.directive("tgKanbanColumnHeightFixer", KanbanColumnHeightFixerDirective)

#############################################################################
## Kanban User Story Directive
#############################################################################

KanbanUserstoryDirective = ($rootscope) ->
    link = ($scope, $el, $attrs, $model) ->
        $el.disableSelection()

        $scope.$watch "us", (us) ->
            if us.is_blocked and not $el.hasClass("blocked")
                $el.addClass("blocked")
            else if not us.is_blocked and $el.hasClass("blocked")
                $el.removeClass("blocked")

        $el.find(".icon-edit").on "click", (event) ->
            if $el.find(".icon-edit").hasClass("noclick")
                return

            $scope.$apply ->
                $rootscope.$broadcast("usform:edit", $model.$modelValue)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "/partials/views/components/kanban-task.html"
        link: link
        require: "ngModel"
    }

module.directive("tgKanbanUserstory", ["$rootScope", KanbanUserstoryDirective])

#############################################################################
## Kanban Squish Column Directive
#############################################################################

KanbanSquishColumnDirective = (rs) ->

    link = ($scope, $el, $attrs) ->
        $scope.$on "project:loaded", (event, project) ->
            $scope.folds = rs.kanban.getStatusColumnModes(project.id)
            updateTableWidth()

        $scope.foldStatus = (status) ->
            $scope.folds[status.id] = !!!$scope.folds[status.id]
            rs.kanban.storeStatusColumnModes($scope.projectId, $scope.folds)
            updateTableWidth()
            return

        updateTableWidth = ->
            columnWidths = _.map $scope.usStatusList, (status) ->
                if $scope.folds[status.id]
                    return 40
                else
                    return 310
            totalWidth = _.reduce columnWidths, (total, width) ->
                return total + width
            $el.find('.kanban-table-inner').css("width", totalWidth)

    return {link: link}

module.directive("tgKanbanSquishColumn", ["$tgResources", KanbanSquishColumnDirective])

#############################################################################
## Kanban WIP Limit Directive
#############################################################################

KanbanWipLimitDirective = ->
    link = ($scope, $el, $attrs) ->
        $el.disableSelection()

        redrawWipLimit = ->
            $el.find(".kanban-wip-limit").remove()
            timeout 200, ->
                element = $el.find(".kanban-task")[$scope.$eval($attrs.tgKanbanWipLimit)]
                if element
                    angular.element(element).before("<div class='kanban-wip-limit'></div>")

        $scope.$on "redraw:wip", redrawWipLimit
        $scope.$on "kanban:us:move", redrawWipLimit
        $scope.$on "usform:new:success", redrawWipLimit
        $scope.$on "usform:bulk:success", redrawWipLimit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgKanbanWipLimit", KanbanWipLimitDirective)


#############################################################################
## Kanban User Directive
#############################################################################

KanbanUserDirective = ($log) ->
    template = _.template("""
    <figure class="avatar">
        <a href="#" title="Assign User Story" <% if (!clickable) {%>class="not-clickable"<% } %>>
            <img src="<%- imgurl %>" alt="<%- name %>" class="avatar">
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
                if $el.find("a").hasClass("noclick")
                    return

                us = $model.$modelValue
                $ctrl = $el.controller()
                $ctrl.changeUsAssignedTo(us)

        bindOnce $scope, "project", (project) ->
            if project.my_permissions.indexOf("modify_us") > -1
                clickable = true
                $el.on "click", (event) =>
                    if $el.find("a").hasClass("noclick")
                        return

                    us = $model.$modelValue
                    $ctrl = $el.controller()
                    $ctrl.changeUsAssignedTo(us)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link, require:"ngModel"}

module.directive("tgKanbanUserAvatar", ["$log", KanbanUserDirective])
