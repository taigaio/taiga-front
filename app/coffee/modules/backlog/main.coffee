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
# File: modules/backlog/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy
timeout = @.taiga.timeout
bindMethods = @.taiga.bindMethods

module = angular.module("taigaBacklog")

#############################################################################
## Backlog Controller
#############################################################################

class BacklogController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
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

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q,
                  @location, @appTitle, @navUrls, @events, @analytics, tgLoader) ->
        bindMethods(@)

        @scope.sectionName = "Backlog"
        @showTags = false
        @activeFilters = false

        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set("Backlog - " + @scope.project.name)

            if @rs.userstories.getShowTags(@scope.projectId)
                @showTags = true

                @scope.$broadcast("showTags", @showTags)

            tgLoader.pageLoaded()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    initializeEventHandlers: ->
        @scope.$on "usform:bulk:success", =>
            @.loadUserstories()
            @.loadProjectStats()
            @analytics.trackEvent("userstory", "create", "bulk create userstory on backlog", 1)

        @scope.$on "sprintform:create:success", =>
            @.loadSprints()
            @.loadProjectStats()
            @analytics.trackEvent("sprint", "create", "create sprint on backlog", 1)

        @scope.$on "usform:new:success", =>
            @.loadUserstories()
            @.loadProjectStats()
            @analytics.trackEvent("userstory", "create", "create userstory on backlog", 1)

        @scope.$on "sprintform:edit:success", =>
            @.loadProjectStats()

        @scope.$on "sprintform:remove:success", =>
            @.loadSprints()
            @.loadProjectStats()
            @.loadUserstories()

        @scope.$on "usform:edit:success", =>
            @.loadUserstories()

        @scope.$on("sprint:us:move", @.moveUs)
        @scope.$on("sprint:us:moved", @.loadSprints)
        @scope.$on("sprint:us:moved", @.loadProjectStats)

    initializeSubscription: ->
        routingKey1 = "changes.project.#{@scope.projectId}.userstories"
        @events.subscribe @scope, routingKey1, (message) =>
            @.loadUserstories()
            @.loadSprints()

        routingKey2 = "changes.project.#{@scope.projectId}.milestones"
        @events.subscribe @scope, routingKey2, (message) =>
            @.loadSprints()

    toggleShowTags: ->
        @scope.$apply =>
            @showTags = !@showTags
            @rs.userstories.storeShowTags(@scope.projectId, @showTags)

    toggleActiveFilters: ->
        @activeFilters = !@activeFilters

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @scope.stats = stats

            if stats.total_points
                @scope.stats.completedPercentage = Math.round(100 * stats.closed_points / stats.total_points)
            else
                @scope.stats.completedPercentage = 0

            return stats

    refreshTagsColors: ->
        return @rs.projects.tagsColors(@scope.projectId).then (tags_colors) =>
            @scope.project.tags_colors = tags_colors

    loadSprints: ->
        return @rs.sprints.list(@scope.projectId).then (sprints) =>
            # NOTE: Fix order of USs because the filter orderBy does not work propertly in partials files
            for sprint in sprints
                sprint.user_stories = _.sortBy(sprint.user_stories, "sprint_order")

            @scope.sprints = sprints
            @scope.sprintsCounter = sprints.length
            @scope.sprintsById = groupBy(sprints, (x) -> x.id)
            @rootscope.$broadcast("sprints:loaded", sprints)
            return sprints

    resetFilters: ->
        selectedTags = _.filter(@scope.filters.tags, "selected")
        selectedStatuses = _.filter(@scope.filters.statuses, "selected")

        @scope.filtersQ = ""

        _.each [selectedTags, selectedStatuses], (filterGrp) =>
            _.each filterGrp, (item) =>
                filters = @scope.filters[item.type]
                filter = _.find(filters, {id: taiga.toString(item.id)})
                filter.selected = false

                @.unselectFilter(item.type, item.id)

        @.loadUserstories()

    loadUserstories: ->
        @scope.httpParams = @.getUrlFilters()
        @rs.userstories.storeQueryParams(@scope.projectId, @scope.httpParams)

        promise = @.refreshTagsColors().then =>
            return @rs.userstories.listUnassigned(@scope.projectId, @scope.httpParams)

        return promise.then (userstories) =>
            # NOTE: Fix order of USs because the filter orderBy does not work propertly in the partials files
            @scope.userstories = _.sortBy(userstories, "backlog_order")

            @.generateFilters()
            @.filterVisibleUserstories()

            @rootscope.$broadcast("filters:loaded", @scope.filters)
            # The broadcast must be executed when the DOM has been fully reloaded.
            # We can't assure when this exactly happens so we need a defer
            scopeDefer @scope, =>
                @scope.$broadcast("userstories:loaded")

            return userstories

    loadBacklog: ->
        return @q.all([
            @.loadProjectStats(),
            @.loadSprints(),
            @.loadUserstories()
        ])

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.points = _.sortBy(project.points, "order")
            @scope.pointsById = groupBy(project.points, (x) -> x.id)
            @scope.usStatusById = groupBy(project.us_statuses, (x) -> x.id)
            @scope.usStatusList = _.sortBy(project.us_statuses, "id")
            return project

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            @.initializeSubscription()
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadBacklog())

    filterVisibleUserstories: ->
        @scope.visibleUserstories = []

        # Filter by tags
        selectedTags = _.filter(@scope.filters.tags, "selected")
        selectedTags = _.map(selectedTags, "name")

        if selectedTags.length == 0
            @scope.visibleUserstories = _.clone(@scope.userstories, false)
        else
            @scope.visibleUserstories = _.reject @scope.userstories, (us) =>
                if _.intersection(selectedTags, us.tags).length == 0
                    return true
                return false

        # Filter by status
        selectedStatuses = _.filter(@scope.filters.statuses, "selected")
        selectedStatuses = _.map(selectedStatuses, "id")

        if selectedStatuses.length > 0
            @scope.visibleUserstories = _.reject @scope.visibleUserstories, (us) =>
                res = _.find(selectedStatuses, (x) -> x == taiga.toString(us.status))
                return not res

        @rs.userstories.storeQueryParams(@scope.projectId, {
            "status": selectedStatuses,
            "tags": selectedTags,
            "project": @scope.projectId
            "milestone": null
        })

    prepareBulkUpdateData: (uses, field="backlog_order") ->
         return _.map(uses, (x) -> {"us_id": x.id, "order": x[field]})

    resortUserStories: (uses, field="backlog_order") ->
        items = []

        for item, index in uses
            item[field] = index
            if item.isModified()
                items.push(item)

        return items

    moveUs: (ctx, usList, newUsIndex, newSprintId) ->
        oldSprintId = usList[0].milestone
        project = usList[0].project

        # In the same sprint or in the backlog
        if newSprintId == oldSprintId
            items = null
            userstories = null

            if newSprintId == null
                userstories = @scope.userstories
            else
                userstories = @scope.sprintsById[newSprintId].user_stories

            @scope.$apply ->
                for us, key in usList
                    r = userstories.indexOf(us)
                    userstories.splice(r, 1)

                args = [newUsIndex, 0].concat(usList)
                Array.prototype.splice.apply(userstories, args)

            # If in backlog
            if newSprintId == null
                # Rehash userstories order field

                items = @.resortUserStories(userstories, "backlog_order")
                data = @.prepareBulkUpdateData(items, "backlog_order")

                # Persist in bulk all affected
                # userstories with order change
                @rs.userstories.bulkUpdateBacklogOrder(project, data).then =>
                    for us in usList
                        @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

            # For sprint
            else
                # Rehash userstories order field
                items = @.resortUserStories(userstories, "sprint_order")
                data = @.prepareBulkUpdateData(items, "sprint_order")

                # Persist in bulk all affected
                # userstories with order change
                @rs.userstories.bulkUpdateSprintOrder(project, data).then =>
                    for us in usList
                        @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

            return promise

        # From sprint to backlog
        if newSprintId == null
            us.milestone = null for us in usList

            @scope.$apply =>
                # Add new us to backlog userstories list
                # @scope.userstories.splice(newUsIndex, 0, us)
                # @scope.visibleUserstories.splice(newUsIndex, 0, us)
                args = [newUsIndex, 0].concat(usList)
                Array.prototype.splice.apply(@scope.userstories, args)
                Array.prototype.splice.apply(@scope.visibleUserstories, args)

                # Execute the prefiltering of user stories
                @.filterVisibleUserstories()

                # Remove the us from the sprint list.
                sprint = @scope.sprintsById[oldSprintId]
                for us, key in usList
                    r = sprint.user_stories.indexOf(us)
                    sprint.user_stories.splice(r, 1)

            # Persist the milestone change of userstory
            promise = @repo.save(us)

            # Rehash userstories order field
            # and persist in bulk all changes.
            promise = promise.then =>
                items = @.resortUserStories(@scope.userstories, "backlog_order")
                data = @.prepareBulkUpdateData(items, "backlog_order")
                return @rs.userstories.bulkUpdateBacklogOrder(us.project, data).then =>
                    @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

            promise.then null, ->
                console.log "FAIL" # TODO

            return promise

        # From backlog to sprint
        newSprint = @scope.sprintsById[newSprintId]
        if oldSprintId == null
            us.milestone = newSprintId for us in usList

            @scope.$apply =>
                args = [newUsIndex, 0].concat(usList)

                # Add moving us to sprint user stories list
                Array.prototype.splice.apply(newSprint.user_stories, args)

                # Remove moving us from backlog userstories lists.
                for us, key in usList
                    r = @scope.visibleUserstories.indexOf(us)
                    @scope.visibleUserstories.splice(r, 1)

                    r = @scope.userstories.indexOf(us)
                    @scope.userstories.splice(r, 1)

        # From sprint to sprint
        else
            us.milestone = newSprintId for us in usList

            @scope.$apply =>
                args = [newUsIndex, 0].concat(usList)

                # Add new us to backlog userstories list
                Array.prototype.splice.apply(newSprint.user_stories, args)

                # Remove the us from the sprint list.
                for us in usList
                    oldSprint = @scope.sprintsById[oldSprintId]
                    r = oldSprint.user_stories.indexOf(us)
                    oldSprint.user_stories.splice(r, 1)

        # Persist the milestone change of userstory
        promises = _.map usList, (us) => @repo.save(us)

        # Rehash userstories order field
        # and persist in bulk all changes.
        promise = @q.all.apply(null, promises).then =>
            items = @.resortUserStories(newSprint.user_stories, "sprint_order")
            data = @.prepareBulkUpdateData(items, "sprint_order")

            return @rs.userstories.bulkUpdateSprintOrder(project, data).then =>
                @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

            return @rs.userstories.bulkUpdateBacklogOrder(project, data).then =>
                for us in usList
                    @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

        promise.then null, ->
            console.log "FAIL" # TODO

        return promise

    getUrlFilters: ->
        return _.pick(@location.search(), "statuses", "tags", "q")

    generateFilters: ->
        urlfilters = @.getUrlFilters()

        if urlfilters.q
            @scope.filtersQ = urlfilters.q

        searchdata = {}
        for name, value of urlfilters
            if not searchdata[name]?
                searchdata[name] = {}

            for val in taiga.toString(value).split(",")
                searchdata[name][val] = true

        isSelected = (type, id) ->
            if searchdata[type]? and searchdata[type][id]
                return true
            return false

        @scope.filters = {}

        plainTags = _.flatten(_.filter(_.map(@scope.userstories, "tags")))
        plainTags.sort()

        @scope.filters.tags = _.map _.countBy(plainTags), (v, k) =>
            obj = {
                id: k,
                type: "tags",
                name: k,
                color: @scope.project.tags_colors[k],
                count: v
            }
            obj.selected = true if isSelected("tags", obj.id)
            return obj

        plainStatuses = _.map(@scope.userstories, "status")

        plainStatuses = _.filter plainStatuses, (status) =>
            if status
                return status

        @scope.filters.statuses = _.map _.countBy(plainStatuses), (v, k) =>
            obj = {
                id: k,
                type: "statuses",
                name: @scope.usStatusById[k].name,
                color: @scope.usStatusById[k].color,
                count:v
            }
            obj.selected = true if isSelected("statuses", obj.id)

            return obj

        return @scope.filters

    ## Template actions

    editUserStory: (us) ->
        @rootscope.$broadcast("usform:edit", us)

    deleteUserStory: (us) ->
        #TODO: i18n
        title = "Delete User Story"
        message = us.subject

        @confirm.askOnDelete(title, message).then (finish) =>
            # We modify the userstories in scope so the user doesn't see the removed US for a while
            @scope.userstories = _.without(@scope.userstories, us)
            @filterVisibleUserstories()
            promise = @.repo.remove(us)
            promise.then =>
                finish()
                @.loadBacklog()
            promise.then null, =>
                finish(false)
                @confirm.notify("error")

    addNewUs: (type) ->
        switch type
            when "standard" then @rootscope.$broadcast("usform:new", @scope.projectId,
                                                       @scope.project.default_us_status, @scope.usStatusList)
            when "bulk" then @rootscope.$broadcast("usform:bulk", @scope.projectId,
                                                   @scope.project.default_us_status)

    addNewSprint: () ->
        @rootscope.$broadcast("sprintform:create", @scope.projectId)

module.controller("BacklogController", BacklogController)


#############################################################################
## Backlog Directive
#############################################################################

BacklogDirective = ($repo, $rootscope) ->
    ## Doom line Link
    doomLineTemplate = _.template("""
    <div class="doom-line"><span>Project Scope [Doomline]</span></div>
    """)
    # TODO: i18n

    linkDoomLine = ($scope, $el, $attrs, $ctrl) ->
        reloadDoomLine = ->
            if $scope.stats?
                removeDoomlineDom()

                elements = getUsItems()
                stats = $scope.stats

                total_points = stats.total_points
                current_sum = stats.assigned_points

                for element in elements
                    scope = element.scope()

                    if not scope.us?
                        continue

                    current_sum += scope.us.total_points

                    if current_sum > total_points
                        addDoomLineDom(element)
                        break

        removeDoomlineDom = ->
            $el.find(".doom-line").remove()

        addDoomLineDom = (element) ->
            element?.before(doomLineTemplate({}))

        getUsItems = ->
            rowElements = $el.find('.backlog-table-body .us-item-row')
            return _.map(rowElements, (x) -> angular.element(x))

        $scope.$on("userstories:loaded", reloadDoomLine)
        $scope.$watch "stats", reloadDoomLine

    ## Move to current sprint link

    linkToolbar = ($scope, $el, $attrs, $ctrl) ->
        moveToCurrentSprint = (selectedUss) ->
            ussCurrent = _($scope.userstories)

            # Remove them from backlog
            $scope.userstories = ussCurrent.without.apply(ussCurrent, selectedUss).value()

            extraPoints = _.map(selectedUss, (v, k) -> v.total_points)
            totalExtraPoints =  _.reduce(extraPoints, (acc, num) -> acc + num)

            # Add them to current sprint
            $scope.sprints[0].user_stories = _.union($scope.sprints[0].user_stories, selectedUss)

            # Update the total of points
            $scope.sprints[0].total_points += totalExtraPoints

            $ctrl.filterVisibleUserstories()
            $repo.saveAll(selectedUss).then ->
                $ctrl.loadSprints()
                $ctrl.loadProjectStats()


        # Enable move to current sprint only when there are selected us's
        $el.on "change", ".backlog-table-body .user-stories input:checkbox", (event) ->
            target = angular.element(event.currentTarget)
            moveToCurrentSprintDom = $el.find("#move-to-current-sprint")
            selectedUsDom = $el.find(".backlog-table-body .user-stories input:checkbox:checked")

            if selectedUsDom.length > 0 and $scope.sprints.length > 0
                moveToCurrentSprintDom.show()
            else
                moveToCurrentSprintDom.hide()

            target.closest('.us-item-row').toggleClass('ui-multisortable-multiple')

        $el.on "click", "#move-to-current-sprint", (event) =>
            # Calculating the us's to be modified
            ussDom = $el.find(".backlog-table-body .user-stories input:checkbox:checked")

            ussToMove = _.map ussDom, (item) ->
                itemScope = angular.element(item).scope()
                itemScope.us.milestone = $scope.sprints[0].id
                return itemScope.us

            $scope.$apply(_.partial(moveToCurrentSprint, ussToMove))

        $el.on "click", "#show-tags", (event) ->
            event.preventDefault()

            $ctrl.toggleShowTags()

            showHideTags($ctrl)

    showHideTags = ($ctrl) ->
        elm = angular.element("#show-tags")

        if $ctrl.showTags
            elm.addClass("active")
            elm.find(".text").text("Hide Tags") # TODO: i18n
        else
            elm.removeClass("active")
            elm.find(".text").text("Show Tags") # TODO: i18n

    showHideFilter = ($scope, $el, $ctrl) ->
        sidebar = $el.find("sidebar.filters-bar")
        sidebar.one "transitionend", () ->
            timeout 150, ->
                $rootscope.$broadcast("resize")
                $('.burndown').css("visibility", "visible")

        target = angular.element("#show-filters-button")
        $('.burndown').css("visibility", "hidden")
        sidebar.toggleClass("active")
        target.toggleClass("active")

        toggleText(target.find(".text"), ["Remove Filters", "Show Filters"]) # TODO: i18n

        if !sidebar.hasClass("active")
            $ctrl.resetFilters()

        $ctrl.toggleActiveFilters()

    ## Filters Link

    linkFilters = ($scope, $el, $attrs, $ctrl) ->
        $scope.filtersSearch = {}
        $el.on "click", "#show-filters-button", (event) ->
            event.preventDefault()
            $scope.$apply ->
                showHideFilter($scope, $el, $ctrl)

    link = ($scope, $el, $attrs, $rootscope) ->
        $ctrl = $el.controller()

        linkToolbar($scope, $el, $attrs, $ctrl)
        linkFilters($scope, $el, $attrs, $ctrl)
        linkDoomLine($scope, $el, $attrs, $ctrl)

        $el.find(".backlog-table-body").disableSelection()

        filters = $ctrl.getUrlFilters()

        if filters.statuses ||
           filters.tags ||
           filters.q
            showHideFilter($scope, $el, $ctrl)

        $scope.$on "showTags", () ->
            showHideTags($ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgBacklog", ["$tgRepo", "$rootScope", BacklogDirective])

#############################################################################
## User story points directive
#############################################################################

UsRolePointsSelectorDirective = ($rootscope) ->
    #TODO: i18n
    selectionTemplate = _.template("""
    <ul class="popover pop-role">
        <li><a class="clear-selection" href="" title="All">All</a></li>
        <% _.each(roles, function(role) { %>
        <li>
            <a href="" class="role" title="<%- role.name %>"
               data-role-id="<%- role.id %>"><%- role.name %></a>
        </li>
        <% }); %>
    </ul>
    """)

    link = ($scope, $el, $attrs) ->
        # Watchers
        bindOnce $scope, "project", (project) ->
            roles = _.filter(project.roles, "computable")
            numberOfRoles = _.size(roles)

            if numberOfRoles > 1
                $el.append(selectionTemplate({"roles":roles}))
            else
                $el.find(".icon-arrow-bottom").remove()
                $el.find(".header-points").addClass("not-clickable")

        $scope.$on "uspoints:select", (ctx, roleId, roleName) ->
            $el.find(".popover").popover().close()
            $el.find(".header-points").html("#{roleName}/<span>Total</span>")

        $scope.$on "uspoints:clear-selection", (ctx, roleId) ->
            $el.find(".popover").popover().close()
            $el.find(".header-points").text("Points") #TODO: i18n

        # Dom Event Handlers
        $el.on "click", (event) ->
            target = angular.element(event.target)

            if target.is("span") or target.is("div")
                event.stopPropagation()

            $el.find(".popover").popover().open()

        $el.on "click", ".clear-selection", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $rootscope.$broadcast("uspoints:clear-selection")

        $el.on "click", ".role", (event) ->
            event.preventDefault()
            event.stopPropagation()

            target = angular.element(event.currentTarget)
            rolScope = target.scope()
            $rootscope.$broadcast("uspoints:select", target.data("role-id"), target.text())

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgUsRolePointsSelector", ["$rootScope", UsRolePointsSelectorDirective])


UsPointsDirective = ($repo) ->
    rolesTemplate = _.template("""
    <ul class="popover pop-role">
        <% _.each(roles, function(role) { %>
        <li>
            <a href="" class="role" title="<%- role.name %>"
               data-role-id="<%- role.id %>">
                <%- role.name %>
                (<%- role.points %>)
            </a>
        </li>
        <% }); %>
    </ul>
    """)

    pointsTemplate = _.template("""
    <ul class="popover pop-points-open">
        <% _.each(points, function(point) { %>
        <li>
            <% if (point.selected) { %>
            <a href="" class="point" title="<%- point.name %>"
               data-point-id="<%- point.id %>"><%- point.name %></a>
            <% } else { %>
            <a href="" class="point active" title="<%- point.name %>"
               data-point-id="<%- point.id %>"><%- point.name %></a>
            <% } %>
        </li>
        <% }); %>
    </ul>
    """)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        us = $scope.$eval($attrs.tgBacklogUsPoints)

        updatingSelectedRoleId = null
        selectedRoleId = null
        numberOfRoles = _.size(us.points)

        # Preselect the role if we have only one
        if numberOfRoles == 1
            selectedRoleId = _.keys(us.points)[0]

        roles = []
        updatePointsRoles = ->
            roles = _.map computableRoles, (role) ->
                pointId = us.points[role.id]
                pointObj = $scope.pointsById[pointId]

                role = _.clone(role, true)
                role.points = if pointObj.value? then pointObj.value else "?"
                return role

        computableRoles = _.filter($scope.project.roles, "computable")
        updatePointsRoles()

        if roles.length == 0
            $el.find(".icon-arrow-bottom").remove()
            $el.find("a.us-points").addClass("not-clickable")

        renderPointsSelector = (us, roleId) ->
            # Prepare data for rendering
            points = _.map $scope.project.points, (point) ->
                point = _.clone(point, true)
                point.selected = if us.points[roleId] == point.id then false else true
                return point

            html = pointsTemplate({"points": points})

            # Remove any prevous state
            $el.find(".popover").popover().close()
            $el.find(".pop-points-open").remove()

            # Render into DOM and show the new created element
            $el.append(html)

            # If not showing role selection let's move to the left
            if not $el.find(".pop-role:visible").css("left")?
                $el.find(".pop-points-open").css("left", "110px")

            $el.find(".pop-points-open").popover().open()

        renderRolesSelector = (us) ->
            updatePointsRoles()

            html = rolesTemplate({"roles": roles})

            # Render into DOM and show the new created element
            $el.append(html)
            $el.find(".pop-role").popover().open(() -> $(this).remove())

        renderPoints = (us, roleId) ->
            dom = $el.find("a > span.points-value")

            if roleId == null or numberOfRoles == 1
                totalPoints = if us.total_points? then us.total_points else "?"
                dom.text(totalPoints)
                dom.parent().prop("title", totalPoints)
            else
                pointId = us.points[roleId]
                pointObj = $scope.pointsById[pointId]
                dom.html("#{pointObj.name} / <span>#{us.total_points}</span>")
                dom.parent().prop("title", "#{pointObj.name} / #{us.total_points}")

        calculateTotalPoints = ->
            values = _.map(us.points, (v, k) -> $scope.pointsById[v].value)
            values = _.filter(values, (num) -> num?)

            if values.length == 0
                return "?"

            return _.reduce(values, (acc, num) -> acc + num)

        $scope.$watch $attrs.tgBacklogUsPoints, (us) ->
            renderPoints(us, selectedRoleId) if us

        $scope.$on "uspoints:select", (ctx, roleId, roleName) ->
            us = $scope.$eval($attrs.tgBacklogUsPoints)
            renderPoints(us, roleId)
            selectedRoleId = roleId

        $scope.$on "uspoints:clear-selection", (ctx) ->
            us = $scope.$eval($attrs.tgBacklogUsPoints)
            renderPoints(us, null)
            selectedRoleId = null

        if roles.length > 0
            $el.on "click", "a.us-points span", (event) ->
                event.preventDefault()
                event.stopPropagation()

                us = $scope.$eval($attrs.tgBacklogUsPoints)
                updatingSelectedRoleId = selectedRoleId

                if selectedRoleId?
                    renderPointsSelector(us, selectedRoleId)
                else
                    renderRolesSelector(us)

            $el.on "click", ".role", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)

                us = $scope.$eval($attrs.tgBacklogUsPoints)

                updatingSelectedRoleId = target.data("role-id")

                popRolesDom = $el.find(".pop-role")
                popRolesDom.find("a").removeClass("active")
                popRolesDom.find("a[data-role-id='#{updatingSelectedRoleId}']").addClass("active")

                renderPointsSelector(us, updatingSelectedRoleId)

            $el.on "click", ".point", (event) ->
                event.preventDefault()
                event.stopPropagation()

                target = angular.element(event.currentTarget)
                $el.find(".pop-points-open").hide()
                $el.find(".pop-role").hide()

                us = $scope.$eval($attrs.tgBacklogUsPoints)

                points = _.clone(us.points, true)
                points[updatingSelectedRoleId] = target.data("point-id")

                $scope.$apply ->
                    us.points = points
                    us.total_points = calculateTotalPoints(us)

                    renderPoints(us, selectedRoleId)

                    $repo.save(us).then ->
                        # Little Hack for refresh.
                        $repo.refresh(us).then ->
                            $ctrl.loadProjectStats()

        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_us") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgBacklogUsPoints", ["$tgRepo", UsPointsDirective])

#############################################################################
## Burndown graph directive
#############################################################################

tgBacklogGraphDirective = ->
    redrawChart = (element, dataToDraw) ->
        width = element.width()
        element.height(width/6)
        milestonesRange = [0..(dataToDraw.milestones.length - 1)]
        data = []
        zero_line = _.map(dataToDraw.milestones, (ml) -> 0)
        data.push({
            data: _.zip(milestonesRange, zero_line)
            lines:
                fillColor : "rgba(0,0,0,0)"
            points:
                show: false
        })
        optimal_line = _.map(dataToDraw.milestones, (ml) -> ml.optimal)
        data.push({
            data: _.zip(milestonesRange, optimal_line)
            lines:
                fillColor : "rgba(120,120,120,0.2)"
        })
        evolution_line = _.filter(_.map(dataToDraw.milestones, (ml) -> ml.evolution), (evolution) -> evolution?)
        data.push({
            data: _.zip(milestonesRange, evolution_line)
            lines:
                fillColor : "rgba(102,153,51,0.3)"
        })
        team_increment_line = _.map(dataToDraw.milestones, (ml) -> -ml["team-increment"])
        data.push({
            data: _.zip(milestonesRange, team_increment_line)
            lines:
                fillColor : "rgba(153,51,51,0.3)"
        })
        client_increment_line = _.map dataToDraw.milestones, (ml) ->
            -ml["team-increment"] - ml["client-increment"]
        data.push({
            data: _.zip(milestonesRange, client_increment_line)
            lines:
                fillColor : "rgba(255,51,51,0.3)"
        })

        colors = [
            "rgba(0,0,0,1)"
            "rgba(120,120,120,0.2)"
            "rgba(102,153,51,1)"
            "rgba(153,51,51,1)"
            "rgba(255,51,51,1)"
        ]

        options = {
            grid: {
                borderWidth: { top: 0, right: 1, left:0, bottom: 0 }
                borderColor: "#ccc"
            }
            xaxis: {
                ticks: dataToDraw.milestones.length
                axisLabel: "Sprints"
                axisLabelUseCanvas: true
                axisLabelFontSizePixels: 14
                axisLabelFontFamily: "Verdana, Arial, Helvetica, Tahoma, sans-serif"
                axisLabelPadding: 15
                tickFormatter: (val, axis) -> ""
            }
            series: {
                shadowSize: 0
                lines: {
                    show: true
                    fill: true
                }
                points: {
                    show: true
                    fill: true
                    radius: 4
                    lineWidth: 2
                }
            }
            colors: colors
        }

        element.empty()
        element.plot(data, options).data("plot")

    link = ($scope, $el, $attrs) ->
        element = angular.element($el)

        $scope.$watch "stats", (value) ->
            if $scope.stats?
                redrawChart(element, $scope.stats)

                $scope.$on "resize", ->
                    redrawChart(element, $scope.stats)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgGmBacklogGraph", tgBacklogGraphDirective)


#############################################################################
## Backlog progress bar directive
#############################################################################

TgBacklogProgressBarDirective = ->
    template = _.template("""
        <div class="defined-points" title="Excess of points"></div>
        <div class="project-points-progress" title="Pending Points" style="width: <%- projectPointsPercentaje %>%"></div>
        <div class="closed-points-progress" title="Closed points" style="width: <%- closedPointsPercentaje %>%"></div>
    """)

    render = (el, projectPointsPercentaje, closedPointsPercentaje) ->
        el.html(template({
            projectPointsPercentaje: projectPointsPercentaje,
            closedPointsPercentaje:closedPointsPercentaje
        }))

    adjustPercentaje = (percentage) ->
        adjusted = _.max([0 , percentage])
        adjusted = _.min([100, adjusted])
        return Math.round(adjusted)

    link = ($scope, $el, $attrs) ->
        element = angular.element($el)

        $scope.$watch $attrs.tgBacklogProgressBar, (stats) ->
            if stats?
                totalPoints = stats.total_points
                definedPoints = stats.defined_points
                closedPoints = stats.closed_points
                if definedPoints > totalPoints
                    projectPointsPercentaje = totalPoints * 100 / definedPoints
                    closedPointsPercentaje = closedPoints * 100 / definedPoints
                else
                    projectPointsPercentaje = 100
                    closedPointsPercentaje = closedPoints * 100 / totalPoints

                projectPointsPercentaje = adjustPercentaje(projectPointsPercentaje - 3)
                closedPointsPercentaje = adjustPercentaje(closedPointsPercentaje - 3)
                render($el, projectPointsPercentaje, closedPointsPercentaje)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgBacklogProgressBar", TgBacklogProgressBarDirective)
