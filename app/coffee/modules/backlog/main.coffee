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
textToColor = @.taiga.textToColor

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
        "$tgLocation"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location) ->
        _.bindAll(@)

        @scope.sectionName = "Backlog"
        @showTags = false

        promise = @.loadInitialData()

        promise.then null, =>
            console.log "FAIL"

        @scope.$on("usform:bulk:success", @.loadUserstories)
        @scope.$on("sprintform:create:success", @.loadSprints)
        @scope.$on("sprintform:create:success", @.loadProjectStats)
        @scope.$on("sprintform:remove:success", @.loadSprints)
        @scope.$on("sprintform:remove:success", @.loadProjectStats)
        @scope.$on("usform:new:success", @.loadUserstories)
        @scope.$on("usform:edit:success", @.loadUserstories)
        @scope.$on("sprint:us:move", @.moveUs)
        @scope.$on("sprint:us:moved", @.loadSprints)
        @scope.$on("sprint:us:moved", @.loadProjectStats)

    toggleShowTags: ->
        @scope.$apply () =>
            @showTags = !@showTags

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @scope.stats = stats

            if stats.total_points
                completedPercentage = Math.round(100 * stats.closed_points / stats.total_points)
            else
                completedPercentage = 0

            @scope.stats.completedPercentage = "#{completedPercentage}%"
            return stats

    loadSprints: ->
        return @rs.sprints.list(@scope.projectId).then (sprints) =>
            @scope.sprints = sprints
            @scope.sprintsCounter = sprints.length
            @scope.sprintsById = groupBy(sprints, (x) -> x.id)
            return sprints

    loadUserstories: ->
        @scope.urlFilters = @.getUrlFilters()

        @scope.httpParams = {}
        for name, values of @scope.urlFilters
            @scope.httpParams[name] = values

        return @rs.userstories.listUnassigned(@scope.projectId, @scope.httpParams).then (userstories) =>
            @scope.userstories = userstories

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

    getUrlFilters: ->
        return _.pick(@location.search(), "statuses", "tags", "subject")

    generateFilters: ->
        urlfilters = @.getUrlFilters()

        if urlfilters.subject
            @scope.filtersSubject = urlfilters.subject

        searchdata = {}
        for name, value of urlfilters
            if not searchdata[name]?
                searchdata[name] = {}

            for val in value.split(",")
                searchdata[name][val] = true

        isSelected = (type, id) ->
            if searchdata[type]? and searchdata[type][id]
                return true
            return false

        @scope.filters = {}

        plainTags = _.flatten(_.map(@scope.userstories, "tags"))
        @scope.filters.tags = _.map _.countBy(plainTags), (v, k) ->
            obj = {
                id: k,
                type: "tags",
                name: k,
                color: textToColor(k),
                count: v
            }
            obj.selected = true if isSelected("tags", obj.id)
            return obj

        plainStatuses = _.map(@scope.userstories, "status")
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
        subtitle = us.subject

        @confirm.ask(title, subtitle).then =>
            # We modify the userstories in scope so the user doesn't see the removed US for a while
            @scope.userstories = _.without(@scope.userstories, us);
            @filterVisibleUserstories()
            @.repo.remove(us).then =>
                @.loadBacklog()

    addNewUs: (type) ->
        switch type
            when "standard" then @rootscope.$broadcast("usform:new", @scope.projectId,
                                                       @scope.project.default_us_status)
            when "bulk" then @rootscope.$broadcast("usform:bulk", @scope.projectId,
                                                   @scope.project.default_us_status)

    addNewSprint: () ->
        @rootscope.$broadcast("sprintform:create")

module.controller("BacklogController", BacklogController)


#############################################################################
## Backlog Directive
#############################################################################

BacklogDirective = ($repo, $rootscope) ->
    #########################
    ## Doom line Link
    #########################
    #TODO: i18n
    doomLineTemplate = _.template("""
    <div class="doom-line"><span>Project Scope [Doomline]</span></div>
    """)

    linkDoomLine = ($scope, $el, $attrs, $ctrl) ->

        removeDoomlineDom = ->
            $el.find(".doom-line").remove()

        addDoomLineDom = (element) ->
            element?.before(doomLineTemplate({}))

        getUsItems = ->
            rowElements = $el.find('.backlog-table-body .us-item-row')
            return _.map(rowElements, (x) -> angular.element(x))

        # reloadDoomlineLocation = () ->
        $scope.$watch "stats", (project) ->
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


    ##############################
    ## Move to current sprint link
    ##############################

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
            moveToCurrentSprintDom = $el.find("#move-to-current-sprint")
            selectedUsDom = $el.find(".backlog-table-body .user-stories input:checkbox:checked")

            if selectedUsDom.length > 0 and $scope.sprints.length > 0
                moveToCurrentSprintDom.show()
            else
                moveToCurrentSprintDom.hide()

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
            target = angular.element(event.currentTarget)
            # $el.find(".user-story-tags").toggle()
            $ctrl.toggleShowTags()
            target.toggleClass("active")
            toggleText(target.find(".text"), ["Hide Tags", "Show Tags"]) # TODO: i18n


    #########################
    ## Filters Link
    #########################

    linkFilters = ($scope, $el, $attrs, $ctrl) ->
        $scope.filtersSearch = {}
        $el.on "click", "#show-filters-button", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            $el.find("sidebar.filters-bar").toggleClass("active")
            target.toggleClass("active")
            toggleText(target.find(".text"), ["Hide Filters", "Show Filters"]) # TODO: i18n
            $rootscope.$broadcast("resize")

    link = ($scope, $el, $attrs, $rootscope) ->
        $ctrl = $el.controller()

        linkToolbar($scope, $el, $attrs, $ctrl)
        linkFilters($scope, $el, $attrs, $ctrl)
        # linkDoomLine($scope, $el, $attrs, $ctrl)

        $el.find(".backlog-table-body").disableSelection()

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

#############################################################################
## User story points directive
#############################################################################

UsRolePointsSelectorDirective = ($rootscope) ->
    #TODO: i18n
    selectionTemplate = _.template("""
      <ul class="popover pop-role">
          <li><a class="clear-selection" href="" title="All">All</a></li>
          <% _.each(roles, function(role) { %>
          <li><a href="" class="role" title="<%- role.name %>"
                 data-role-id="<%- role.id %>"><%- role.name %></a></li>
          <% }); %>
      </ul>
    """)

    link = ($scope, $el, $attrs) ->
        # Watchers
        bindOnce $scope, "project", (project) ->
            roles = _.filter(project.roles, "computable")
            numberOfRoles = _.size(roles)

            if numberOfRoles > 1
                $el.append(selectionTemplate({ 'roles':  roles }))
            else
                $el.find(".icon-arrow-bottom").remove()

        $scope.$on "uspoints:select", (ctx, roleId, roleName) ->
            $el.find(".popover").hide()
            $el.find(".header-points").html("#{roleName}/<span>Total</span>")

        $scope.$on "uspoints:clear-selection", (ctx, roleId) ->
            $el.find(".popover").hide()
            $el.find(".header-points").text("Points") #TODO: i18n

        # Dom Event Handlers
        $el.on "click", (event) ->
            target = angular.element(event.target)

            if target.is("span") or target.is("div")
                event.stopPropagation()

            $el.find(".popover").show()
            body = angular.element("body")
            body.one "click", (event) ->
                $el.find(".popover").hide()

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


UsPointsDirective = ($repo) ->
    selectionTemplate = _.template("""
    <ul class="popover pop-role">
        <% _.each(rolePoints, function(rolePointsElement) { %>
        <li><a href="" class="role" title="<%- rolePointsElement.name %>"
               data-role-id="<%- rolePointsElement.id %>">
               <%- rolePointsElement.name %>
               (<%- rolePointsElement.points %>)
            </a>
        </li>
        <% }); %>
    </ul>
    """)

    pointsTemplate = _.template("""
    <ul class="popover pop-points-open">
        <% _.each(points, function(point) { %>
        <li><a href="" class="point" title="<%- point.name %>"
               data-point-id="<%- point.id %>"><%- point.name %></a>
        </li>
        <% }); %>
    </ul>
    """)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        us = $scope.$eval($attrs.tgUsPoints)
        updatingSelectedRoleId = null
        selectedRoleId = null
        numberOfRoles = _.size(us.points)

        # Preselect the rol if we have only one
        if numberOfRoles == 1
            selectedRoleId = _.keys(us.points)[0]

        showPopPoints = () ->
            $(".popover").hide()
            $el.find(".pop-points-open").remove()
            $el.append(pointsTemplate({ "points":  $scope.project.points }))
            dataPointId = us.points[updatingSelectedRoleId]
            $el.find(".pop-points-open a[data-point-id='#{dataPointId}']").addClass("active")

            # If not showing role selection let's move to the left
            if not $el.find(".pop-role:visible").css('left')?
                $el.find(".pop-points-open").css('left', '110px')

            $el.find(".pop-points-open").show()

        showPopRoles = () ->
            $(".popover").hide()
            $el.find(".pop-role").remove()
            rolePoints = _.clone(_.filter($scope.project.roles, "computable"), true)

            undefinedToQuestion = (val) ->
                return "?" if not val?
                return val

            _.map rolePoints, (v, k) ->
                v.points = undefinedToQuestion($scope.pointsById[us.points[v.id]].value)
            $el.append(selectionTemplate({ "rolePoints":  rolePoints }))
            $el.find(".pop-role").show()

        updatePoints = (roleId) ->
            # Update the dom with the points
            pointsDom = $el.find("a > span.points-value")
            usTotalPoints = calculateTotalPoints(us)
            us.total_points = usTotalPoints
            if not roleId? or numberOfRoles == 1
                pointsDom.text(us.total_points)
            else
                pointId = us.points[roleId]
                points = $scope.pointsById[pointId]
                pointsDom.html("#{points.name} / <span>#{us.total_points}</span>")

        calculateTotalPoints = ->
            values = _.map(us.points, (v, k) -> $scope.pointsById[v].value)
            values = _.filter(values, (num) -> num?)
            if values.length == 0
                return "?"

            return _.reduce(values, (acc, num) -> acc + num)

        updatePoints(null)

        $scope.$on "uspoints:select", (ctx, roleId, roleName) ->
            updatePoints(roleId)
            selectedRoleId = roleId

        $scope.$on "uspoints:clear-selection", (ctx) ->
            updatePoints(null)
            selectedRoleId = null

        $el.on "click", "a.us-points span", (event) ->
            event.preventDefault()
            target = angular.element(event.target)

            event.stopPropagation()

            if selectedRoleId?
                updatingSelectedRoleId = selectedRoleId
                showPopPoints()
            else
                showPopRoles()

            body = angular.element("body")
            body.one "click", (event) ->
                $el.find(".popover").hide()

        $el.on "click", ".role", (event) ->
            event.preventDefault()
            event.stopPropagation()

            target = angular.element(event.currentTarget)
            updatingSelectedRoleId = target.data("role-id")

            popRolesDom = $el.find(".pop-role")
            popRolesDom.find("a").removeClass("active")
            popRolesDom.find("a[data-role-id='#{updatingSelectedRoleId}']").addClass("active")
            showPopPoints()

        $el.on "click", ".point", (event) ->
            event.preventDefault()
            event.stopPropagation()

            target = angular.element(event.currentTarget)
            $el.find(".pop-points-open").hide()
            $el.find(".pop-role").hide()

            $scope.$apply () ->
                usPoints = _.clone(us.points, true)
                usPoints[updatingSelectedRoleId] = target.data("point-id")
                us.points = usPoints

                usTotalPoints = calculateTotalPoints(us)
                us.total_points = usTotalPoints

                updatePoints(selectedRoleId)

                $repo.save(us).then ->
                    # Little Hack for refresh.
                    $repo.refresh(us).then ->
                        $ctrl.loadProjectStats()

        taiga.bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_us") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


#############################################################################
## Burndown graph directive
#############################################################################

tgBacklogGraphDirective = ->
    redrawChart = (element, dataToDraw) ->
        width = element.width()
        element.height(width/6)
        milestones = _.map(dataToDraw.milestones, (ml) -> ml.name)
        milestonesRange = [0..(milestones.length - 1)]
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
        team_increment_line = _.map(dataToDraw.milestones, (ml) -> -ml['team-increment'])
        data.push({
            data: _.zip(milestonesRange, team_increment_line)
            lines:
                fillColor : "rgba(153,51,51,0.3)"
        })
        client_increment_line = _.map dataToDraw.milestones, (ml) ->
            -ml['team-increment'] - ml['client-increment']
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
                borderColor: '#ccc'
            }
            xaxis: {
                ticks: _.zip(milestonesRange, milestones)
                axisLabelUseCanvas: true
                axisLabelFontSizePixels: 12
                axisLabelFontFamily: 'Verdana, Arial, Helvetica, Tahoma, sans-serif'
                axisLabelPadding: 5
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

        $scope.$watch 'stats', (value) ->
            if $scope.stats?
                redrawChart(element, $scope.stats)

                $scope.$on "resize", ->
                    redrawChart(element, $scope.stats)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgBacklog", ["$tgRepo", "$rootScope", BacklogDirective])
module.directive("tgUsPoints", ["$tgRepo", UsPointsDirective])
module.directive("tgUsRolePointsSelector", ["$rootScope", UsRolePointsSelectorDirective])
module.directive("tgGmBacklogGraph", tgBacklogGraphDirective)
