###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
generateHash = @.taiga.generateHash

module = angular.module("taigaBacklog")

#############################################################################
## Backlog Controller
#############################################################################

class BacklogController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin, taiga.UsFiltersMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "tgAppMetaService",
        "$tgNavUrls",
        "$tgEvents",
        "$tgAnalytics",
        "$translate",
        "$tgLoading",
        "tgResources",
        "$tgQueueModelTransformation",
        "tgErrorHandlingService",
        "$tgStorage",
        "tgFilterRemoteStorageService",
        "tgProjectService"
    ]

    storeCustomFiltersName: 'backlog-custom-filters'
    storeFiltersName: 'backlog-filters'
    backlogOrder: {}
    milestonesOrder: {}

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @appMetaService, @navUrls,
                  @events, @analytics, @translate, @loading, @rs2, @modelTransform, @errorHandlingService,
                  @storage, @filterRemoteStorageService, @projectService) ->
        bindMethods(@)

        @.backlogOrder = {}
        @.milestonesOrder = {}

        @.page = 1
        @.disablePagination = false
        @.firstLoadComplete = false
        @scope.userstories = []

        return if @.applyStoredFilters(@params.pslug, "backlog-filters")

        @scope.sectionName = @translate.instant("BACKLOG.SECTION_NAME")
        @showTags = false
        @activeFilters = false
        @scope.showGraphPlaceholder = null
        @displayVelocity = false

        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @.firstLoadComplete = true

            title = @translate.instant("BACKLOG.PAGE_TITLE", {projectName: @scope.project.name})
            description = @translate.instant("BACKLOG.PAGE_DESCRIPTION", {
                projectName: @scope.project.name,
                projectDescription: @scope.project.description
            })
            @appMetaService.setAll(title, description)

            if @rs.userstories.getShowTags(@scope.projectId)
                @showTags = true

                @scope.$broadcast("showTags", @showTags)

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    filtersReloadContent: () ->
        @.loadUserstories(true)

    initializeEventHandlers: ->
        @scope.$on "usform:bulk:success", =>
            @.loadUserstories(true)
            @.loadProjectStats()
            @confirm.notify("success")
            @analytics.trackEvent("userstory", "create", "bulk create userstory on backlog", 1)

        @scope.$on "sprintform:create:success", (e, data, ussToMove) =>
            @.loadSprints().then () =>
                @scope.$broadcast("sprintform:create:success:callback", ussToMove)

            @.loadProjectStats()
            @confirm.notify("success")
            @analytics.trackEvent("sprint", "create", "create sprint on backlog", 1)

        @scope.$on "usform:new:success", =>
            @.loadUserstories(true)
            @.loadProjectStats()

            @rootscope.$broadcast("filters:update")
            @confirm.notify("success")
            @analytics.trackEvent("userstory", "create", "create userstory on backlog", 1)

        @scope.$on "sprintform:edit:success", =>
            @.loadProjectStats()

        @scope.$on "sprintform:remove:success", (event, sprint) =>
            @.loadSprints()
            @.loadProjectStats()
            @.loadUserstories(true)

            if sprint.closed
                @.loadClosedSprints()

            @rootscope.$broadcast("filters:update")

        @scope.$on "usform:edit:success", (event, data) =>
            index = _.findIndex @scope.userstories, (us) ->
                return us.id == data.id

            @scope.userstories[index] = data

            @rootscope.$broadcast("filters:update")

        @scope.$on("sprint:us:move", @.moveUs)
        @scope.$on "sprint:us:moved", () =>
            @.loadSprints()
            @.loadClosedSprints()
            @.loadProjectStats()

        @scope.$on("backlog:load-closed-sprints", @.loadClosedSprints)
        @scope.$on("backlog:unload-closed-sprints", @.unloadClosedSprints)

    initializeSubscription: ->
        routingKey1 = "changes.project.#{@scope.projectId}.userstories"
        @events.subscribe @scope, routingKey1, (message) =>
            @.loadAllPaginatedUserstories()
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

    toggleVelocityForecasting: ->
        @displayVelocity = !@displayVelocity
        if !@displayVelocity
            @scope.visibleUserStories = _.map @scope.userstories, (it) ->
                return it.ref
        else
            @scope.visibleUserStories = _.map @.forecastedStories, (it) ->
                return it.ref
        scopeDefer @scope, =>
            @scope.$broadcast("userstories:loaded")

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @scope.stats = stats
            totalPoints = if stats.total_points then stats.total_points else stats.defined_points

            if totalPoints
                @scope.stats.completedPercentage = Math.round(100 * stats.closed_points / totalPoints)
            else
                @scope.stats.completedPercentage = 0

            @scope.showGraphPlaceholder = !(stats.total_points? && stats.total_milestones?)
            @.calculateForecasting()
            return stats

    setMilestonesOrder: (sprints) ->
        for sprint in sprints
            @.milestonesOrder[sprint.id] = {}
            for it in sprint.user_stories
                @.milestonesOrder[sprint.id][it.id] = it.sprint_order

    unloadClosedSprints: ->
        @scope.$apply =>
            @scope.closedSprints =  []
            @rootscope.$broadcast("closed-sprints:reloaded", [])

    loadClosedSprints: ->
        params = {closed: true}
        return @rs.sprints.list(@scope.projectId, params).then (result) =>
            sprints = result.milestones

            @.setMilestonesOrder(sprints)

            @scope.totalClosedMilestones = result.closed

            # NOTE: Fix order of USs because the filter orderBy does not work propertly in partials files
            for sprint in sprints
                sprint.user_stories = _.sortBy(sprint.user_stories, "sprint_order")
            @scope.closedSprints =  sprints
            @scope.closedSprintsById = groupBy(sprints, (x) -> x.id)
            @rootscope.$broadcast("closed-sprints:reloaded", sprints)
            return sprints

    loadSprints: ->
        params = {closed: false}
        return @rs.sprints.list(@scope.projectId, params).then (result) =>
            sprints = result.milestones

            @.setMilestonesOrder(sprints)

            @scope.totalMilestones = sprints
            @scope.totalClosedMilestones = result.closed
            @scope.totalOpenMilestones = result.open
            @scope.totalMilestones = @scope.totalOpenMilestones + @scope.totalClosedMilestones

            # NOTE: Fix order of USs because the filter orderBy does not work propertly in partials files
            for sprint in sprints
                sprint.user_stories = _.sortBy(sprint.user_stories, "sprint_order")

            @scope.sprints = sprints

            @scope.closedSprints =  [] if !@scope.closedSprints

            @scope.sprintsCounter = sprints.length
            @scope.sprintsById = groupBy(sprints, (x) -> x.id)
            @rootscope.$broadcast("sprints:loaded", sprints)

            @scope.currentSprint = @.findCurrentSprint()

            return sprints

    openSprints: ->
        return _.filter(@scope.sprints, (sprint) => not sprint.closed).reverse()

    loadAllPaginatedUserstories: () ->
        page = @.page

        @.loadUserstories(true, @scope.userstories.length).then () =>
          @.page = page

    loadUserstories: (resetPagination = false, pageSize) ->
        return null if !@scope.projectId

        @.loadingUserstories = true
        @.disablePagination = true
        params = _.clone(@location.search())
        @rs.userstories.storeQueryParams(@scope.projectId, params)

        if resetPagination
            @.page = 1

        params.page = @.page

        promise = @rs.userstories.listUnassigned(@scope.projectId, params, pageSize)

        return promise.then (result) =>

            userstories = result[0]
            header = result[1]

            if resetPagination
                @scope.userstories = []

            # NOTE: Fix order of USs because the filter orderBy does not work propertly in the partials files
            @scope.userstories = @scope.userstories.concat(_.sortBy(userstories, "backlog_order"))
            @scope.visibleUserStories = _.map @scope.userstories, (it) ->
                return it.ref

            for it in @scope.userstories
                @.backlogOrder[it.id] = it.backlog_order

            @.loadingUserstories = false

            if header('x-pagination-next')
                @.disablePagination = false
                @.page++

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
        ]).then(@.calculateForecasting)

    calculateForecasting: ->
        stats = @scope.stats
        total_points = stats.total_points
        current_sum = stats.assigned_points
        backlog_points_sum = 0
        @forecastedStories = []

        for us in @scope.userstories
            current_sum += us.total_points
            backlog_points_sum += us.total_points
            @forecastedStories.push(us)

            if stats.speed > 0 && backlog_points_sum > stats.speed
                break

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.is_backlog_activated
            @errorHandlingService.permissionDenied()

        @scope.projectId = project.id
        @scope.project = project
        @scope.closedMilestones = !!project.total_closed_milestones
        @scope.$emit('project:loaded', project)
        @scope.points = _.sortBy(project.points, "order")
        @scope.pointsById = groupBy(project.points, (x) -> x.id)
        @scope.usStatusById = groupBy(project.us_statuses, (x) -> x.id)
        @scope.usStatusList = _.sortBy(project.us_statuses, "id")

        return project

    loadInitialData: ->
        project = @.loadProject()

        @.fillUsersAndRoles(project.members, project.roles)
        @.initializeSubscription()

        return @.loadBacklog()
            .then(=> @.generateFilters(milestone = "null"))
            .then(=> @scope.$emit("backlog:loaded"))

    prepareBulkUpdateData: (uses, field="backlog_order") ->
         return _.map(uses, (x) -> {"us_id": x.id, "order": x[field]})

    # --move us api behavior--
    # If your are moving multiples USs you must use the bulk api
    # If there is only one US you must use patch (repo.save)
    #
    # The new US position is the position of the previous US + 1.
    # If the previous US has a position value that it is equal to
    # other USs, you must send all the USs with that position value
    # only if they are before of the target position with this USs
    # if it's a patch you must add them to the header, if is a bulk
    # you must send them with the other USs
    moveUs: (ctx, usList, newUsIndex, newSprintId) ->
        oldSprintId = usList[0].milestone
        project = usList[0].project

        if oldSprintId
            sprint = @scope.sprintsById[oldSprintId] || @scope.closedSprintsById[oldSprintId]

        if newSprintId
            newSprint = @scope.sprintsById[newSprintId] || @scope.closedSprintsById[newSprintId]

        currentSprintId = if newSprintId != oldSprintId then newSprintId else oldSprintId

        orderList = null
        orderField = ""

        if newSprintId != oldSprintId
            if newSprintId == null # From sprint to backlog
                for us, key in usList # delete from sprint userstories
                    _.remove sprint.user_stories, (it) -> it.id == us.id

                orderField = "backlog_order"
                orderList = @.backlogOrder

                beforeDestination = _.slice(@scope.userstories, 0, newUsIndex)
                afterDestination = _.slice(@scope.userstories, newUsIndex)

                @scope.userstories = @scope.userstories.concat(usList)
            else # From backlog to sprint
                for us in usList # delete from sprint userstories
                    _.remove @scope.userstories, (it) -> it.id == us.id

                orderField = "sprint_order"
                orderList = @.milestonesOrder[newSprint.id]

                beforeDestination = _.slice(newSprint.user_stories, 0, newUsIndex)
                afterDestination = _.slice(newSprint.user_stories, newUsIndex)

                newSprint.user_stories = newSprint.user_stories.concat(usList)
        else
            if oldSprintId == null # backlog
                orderField = "backlog_order"
                orderList = @.backlogOrder

                list = _.filter @scope.userstories, (listIt) -> # Remove moved US from list
                    return !_.find usList, (moveIt) -> return listIt.id == moveIt.id

                beforeDestination = _.slice(list, 0, newUsIndex)
                afterDestination = _.slice(list, newUsIndex)
            else # sprint
                orderField = "sprint_order"
                orderList = @.milestonesOrder[sprint.id]

                list = _.filter newSprint.user_stories, (listIt) -> # Remove moved US from list
                    return !_.find usList, (moveIt) -> return listIt.id == moveIt.id

                beforeDestination = _.slice(list, 0, newUsIndex)
                afterDestination = _.slice(list, newUsIndex)

        # previous us
        previous = beforeDestination[beforeDestination.length - 1]

        # this will store the previous us with the same position
        setPreviousOrders = []

        if !previous
            startIndex = 0
        else if previous
            startIndex = orderList[previous.id] + 1

            previousWithTheSameOrder = _.filter(beforeDestination, (it) ->
                it[orderField] == orderList[previous.id]
            )

            # we must send the USs previous to the dropped USs to tell the backend
            # which USs are before the dropped USs, if they have the same value to
            # order, the backend doens't know after which one do you want to drop
            # the USs
            if previousWithTheSameOrder.length > 1
                setPreviousOrders = _.map(previousWithTheSameOrder, (it) ->
                    {us_id: it.id, order: orderList[it.id]}
                )

        modifiedUs = []

        for us, key in usList # update sprint and new position
            us.milestone = currentSprintId
            us[orderField] = startIndex + key
            orderList[us.id] = us[orderField]

            modifiedUs.push({us_id: us.id, order: us[orderField]})

        startIndex = orderList[usList[usList.length - 1].id]

        for it, key in afterDestination # increase position of the us after the dragged us's
            orderList[it.id] = startIndex + key + 1

        setNextOrders = _.map(afterDestination, (it) =>
            {us_id: it.id, order: orderList[it.id]}
        )

        # refresh order
        @scope.userstories = _.sortBy @scope.userstories, (it) => @.backlogOrder[it.id]
        @scope.visibleUserStories = _.map @scope.userstories, (it) -> return it.ref

        for sprint in @scope.sprints
            sprint.user_stories = _.sortBy sprint.user_stories, (it) => @.milestonesOrder[sprint.id][it.id]

        for sprint in @scope.closedSprints
            sprint.user_stories = _.sortBy sprint.user_stories, (it) => @.milestonesOrder[sprint.id][it.id]

        # saving
        if usList.length > 1 && (newSprintId != oldSprintId) # drag multiple to sprint
            data = modifiedUs.concat(setPreviousOrders, setNextOrders)
            promise = @rs.userstories.bulkUpdateMilestone(project, newSprintId, data)
        else if usList.length > 1 # drag multiple in backlog
            data = modifiedUs.concat(setPreviousOrders, setNextOrders)
            promise = @rs.userstories.bulkUpdateBacklogOrder(project, data)
        else  # drag single
            setOrders = {}
            for it in setPreviousOrders
                setOrders[it.us_id] = it.order
            for it in setNextOrders
                setOrders[it.us_id] = it.order

            options = {
                headers: {
                    "set-orders": JSON.stringify(setOrders)
                }
            }

            promise = @repo.save(usList[0], true, {}, options, true)

        promise.then () =>
            @rootscope.$broadcast("sprint:us:moved")

            if @scope.closedSprintsById && @scope.closedSprintsById[oldSprintId]
                @rootscope.$broadcast("backlog:load-closed-sprints")

        return promise

    ## Template actions

    updateUserStoryStatus: () ->
        @.generateFilters().then () =>
            @rootscope.$broadcast("filters:update")
            @.loadProjectStats()
            if @.isFilterDataTypeSelected('status')
                @.filtersReloadContent()

    editUserStory: (projectId, ref, $event) ->
        target = $($event.target)

        currentLoading = @loading()
            .target(target)
            .removeClasses("edit-story")
            .timeout(200)
            .start()

        return @rs.userstories.getByRef(projectId, ref).then (us) =>
            @rs2.attachments.list("us", us.id, projectId).then (attachments) =>
                @rootscope.$broadcast("genericform:edit", {
                    'objType': 'us',
                    'obj': us,
                    'attachments': attachments.toJS()
                })
                currentLoading.finish()

    deleteUserStory: (us) ->
        title = @translate.instant("US.TITLE_DELETE_ACTION")

        message = us.subject

        @confirm.askOnDelete(title, message).then (askResponse) =>
            # We modify the userstories in scope so the user doesn't see the removed US for a while
            @scope.userstories = _.without(@scope.userstories, us)
            promise = @.repo.remove(us)
            promise.then =>
                askResponse.finish()

                @q.all([
                    @.loadProjectStats(),
                    @.loadSprints()
                ])
            promise.then null, =>
                askResponse.finish(false)
                @confirm.notify("error")

    addNewUs: (type) ->
        switch type
            when "standard" then @rootscope.$broadcast("genericform:new",
                {
                    'objType': 'us',
                    'project': @scope.project
                })
            when "bulk" then @rootscope.$broadcast("usform:bulk", @scope.projectId,
                                                   @scope.project.default_us_status)

    addNewSprint: () ->
        @rootscope.$broadcast("sprintform:create", @scope.projectId)

    findCurrentSprint: () ->
        currentDate = new Date().getTime()

        return  _.find @scope.sprints, (sprint) ->
            start = moment(sprint.estimated_start, 'YYYY-MM-DD').format('x')
            end = moment(sprint.estimated_finish, 'YYYY-MM-DD').format('x')

            return currentDate >= start && currentDate <= end

module.controller("BacklogController", BacklogController)

#############################################################################
## Backlog Directive
#############################################################################

BacklogDirective = ($repo, $rootscope, $translate, $rs) ->
    ## Doom line Link
    doomLineTemplate = _.template("""
    <div class="doom-line"><span><%- text %></span></div>
    """)

    linkDoomLine = ($scope, $el, $attrs, $ctrl) ->
        reloadDoomLine = ->
            if $scope.displayVelocity
                removeDoomlineDom()

            if $scope.stats? and $scope.stats.total_points? and $scope.stats.total_points != 0 and !$scope.displayVelocity?
                removeDoomlineDom()

                stats = $scope.stats
                total_points = stats.total_points
                current_sum = stats.assigned_points

                return if not $scope.userstories

                for us, i in $scope.userstories
                    current_sum += us.total_points

                    if current_sum > total_points
                        domElement = $el.find('.backlog-table-body .us-item-row')[i]
                        addDoomLineDom(domElement)

                        break

        removeDoomlineDom = ->
            $el.find(".doom-line").remove()

        addDoomLineDom = (element) ->
            text = $translate.instant("BACKLOG.DOOMLINE")
            $(element).before(doomLineTemplate({"text": text}))

        getUsItems = ->
            rowElements = $el.find('.backlog-table-body .us-item-row')
            return _.map(rowElements, (x) -> angular.element(x))

        $scope.$on("userstories:loaded", reloadDoomLine)
        $scope.$on("userstories:forecast", removeDoomlineDom)
        $scope.$watch("stats", reloadDoomLine)

    ## Move to current sprint link

    linkToolbar = ($scope, $el, $attrs, $ctrl) ->
        getUsToMove = () ->
            # Calculating the us's to be modified
            ussDom = $el.find(".backlog-table-body input:checkbox:checked")

            return _.map ussDom, (item) ->
                item =  $(item).closest('.tg-scope')
                itemScope = item.scope()
                itemScope.us.milestone = $scope.sprints[0].id
                return itemScope.us

        moveUssToSprint = (selectedUss, sprint) ->
            ussCurrent = _($scope.userstories)

            # Remove them from backlog
            $scope.userstories = ussCurrent.without.apply(ussCurrent, selectedUss).value()

            extraPoints = _.map(selectedUss, (v, k) -> v.total_points)
            totalExtraPoints =  _.reduce(extraPoints, (acc, num) -> acc + num)

            # Add them to current sprint
            sprint.user_stories = _.union(sprint.user_stories, selectedUss)

            # Update the total of points
            sprint.total_points += totalExtraPoints

            data = _.map selectedUss, (us) ->
                return {
                    us_id: us.id
                    order: us.sprint_order
                }
            $rs.userstories.bulkUpdateMilestone($scope.project.id, $scope.sprints[0].id, data).then =>
                $ctrl.loadSprints()
                $ctrl.loadProjectStats()
                $ctrl.toggleVelocityForecasting()
                $ctrl.calculateForecasting()

            $el.find(".move-to-sprint").hide()

        moveToCurrentSprint = (selectedUss) ->
            moveUssToSprint(selectedUss, $scope.currentSprint)

        moveToLatestSprint = (selectedUss) ->
            moveUssToSprint(selectedUss, $scope.sprints[0])

        $scope.$on "sprintform:create:success:callback", (e, ussToMove) ->
            _.partial(moveToCurrentSprint, ussToMove)()

        shiftPressed = false
        lastChecked = null

        checkSelected = (target) ->
            lastChecked = target.closest(".us-item-row")
            target.closest('.us-item-row').toggleClass('ui-multisortable-multiple')
            moveToSprintDom = $el.find(".move-to-sprint")
            selectedUsDom = $el.find(".backlog-table-body input:checkbox:checked")

            if selectedUsDom.length > 0 and $scope.sprints.length > 0
                moveToSprintDom.show()
            else
                moveToSprintDom.hide()


        $(window).on "keydown.shift-pressed keyup.shift-pressed", (event) ->
            shiftPressed = !!event.shiftKey

            return true

        # Enable move to current sprint only when there are selected us's
        $el.on "change", ".backlog-table-body input:checkbox", (event) ->
            # check elements between the last two if shift is pressed
            if lastChecked && shiftPressed
                elements = []
                current = $(event.currentTarget).closest(".us-item-row")
                nextAll = lastChecked.nextAll()
                prevAll = lastChecked.prevAll()

                if _.some(nextAll, (next) -> next == current[0])
                    elements = lastChecked.nextUntil(current)
                else if _.some(prevAll, (prev) -> prev == current[0])
                    elements = lastChecked.prevUntil(current)

                _.map elements, (elm) ->
                    input = $(elm).find("input:checkbox")
                    input.prop('checked', true)
                    checkSelected(input)

            target = angular.element(event.currentTarget)
            target.closest(".us-item-row").toggleClass('is-checked')
            checkSelected(target)

        $el.on "click", "#move-to-latest-sprint", (event) =>
            ussToMove = getUsToMove()

            $scope.$apply(_.partial(moveToLatestSprint, ussToMove))

        $el.on "click", "#move-to-current-sprint", (event) =>
            ussToMove = getUsToMove()

            $scope.$apply(_.partial(moveToCurrentSprint, ussToMove))

        $el.on "click", "#show-tags", (event) ->
            event.preventDefault()

            $ctrl.toggleShowTags()

            showHideTags($ctrl)

        $el.on "click", ".forecasting-add-sprint", (event) ->
            ussToMoveList = $ctrl.forecastedStories
            if $scope.currentSprint
                ussToMove = _.map ussToMoveList, (us, index) ->
                    us.milestone = $scope.currentSprint.id
                    us.order = index
                    return us

                $scope.$apply(_.partial(moveToCurrentSprint, ussToMove))
            else
                ussToMove = _.map ussToMoveList, (us, index) ->
                    us.order = index
                    return us

                $rootscope.$broadcast("sprintform:create", $scope.projectId, ussToMove)

    showHideTags = ($ctrl) ->
        elm = angular.element("#show-tags")

        if $ctrl.showTags
            elm.addClass("active")

            text = $translate.instant("BACKLOG.TAGS.HIDE")
            elm.text(text)
        else
            elm.removeClass("active")

            text = $translate.instant("BACKLOG.TAGS.SHOW")
            elm.text(text)

    openFilterInit = ($scope, $el, $ctrl) ->
        sidebar = $el.find("sidebar.backlog-filter")

        sidebar.addClass("active")

        $ctrl.activeFilters = true

    showHideFilter = ($scope, $el, $ctrl) ->
        sidebar = $el.find("sidebar.backlog-filter")
        sidebar.one "transitionend", () ->
            timeout 150, ->
                $rootscope.$broadcast("resize")
                $('.burndown').css("visibility", "visible")

        target = angular.element("#show-filters-button")
        $('.burndown').css("visibility", "hidden")
        sidebar.toggleClass("active")
        target.toggleClass("active")

        hideText = $translate.instant("BACKLOG.FILTERS.HIDE")
        showText = $translate.instant("BACKLOG.FILTERS.SHOW")

        toggleText(target, [hideText, showText])

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

        filters = $ctrl.location.search()
        if filters.status ||
           filters.tags ||
           filters.q ||
           filters.assigned_to ||
           filters.owner
            openFilterInit($scope, $el, $ctrl)

        $scope.$on "showTags", () ->
            showHideTags($ctrl)

        $scope.$on "$destroy", ->
            $el.off()
            $(window).off(".shift-pressed")

    return {link: link}


module.directive("tgBacklog", ["$tgRepo", "$rootScope", "$translate", "$tgResources", BacklogDirective])

#############################################################################
## User story points directive
#############################################################################

UsRolePointsSelectorDirective = ($rootscope, $template, $compile, $translate) ->
    selectionTemplate = $template.get("backlog/us-role-points-popover.html", true)

    link = ($scope, $el, $attrs) ->
        # Watchers
        bindOnce $scope, "project", (project) ->
            roles = _.filter(project.roles, "computable")
            numberOfRoles = _.size(roles)

            if numberOfRoles > 1
                $el.append($compile(selectionTemplate({"roles": roles}))($scope))
            else
                $el.find(".icon-arrow-down").remove()
                $el.find(".header-points").addClass("not-clickable")

        $scope.$on "uspoints:select", (ctx, roleId, roleName) ->
            $el.find(".popover").popover().close()
            $el.find(".header-points").html("#{roleName}/<span>Total</span>")

        $scope.$on "uspoints:clear-selection", (ctx, roleId) ->
            $el.find(".popover").popover().close()

            text = $translate.instant("COMMON.FIELDS.POINTS")
            $el.find(".header-points").text(text)

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

module.directive("tgUsRolePointsSelector", ["$rootScope", "$tgTemplate", "$compile", "$translate", UsRolePointsSelectorDirective])


UsPointsDirective = ($tgEstimationsService, $repo, $tgTemplate) ->
    rolesTemplate = $tgTemplate.get("common/estimation/us-points-roles-popover.html", true)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        updatingSelectedRoleId = null
        selectedRoleId = null
        filteringRoleId = null
        estimationProcess = null

        $scope.$on "uspoints:select", (ctx, roleId, roleName) ->
            us = $scope.$eval($attrs.tgBacklogUsPoints)
            selectedRoleId = roleId
            estimationProcess.render()

        $scope.$on "uspoints:clear-selection", (ctx) ->
            us = $scope.$eval($attrs.tgBacklogUsPoints)
            selectedRoleId = null
            estimationProcess.render()

        $scope.$watch $attrs.tgBacklogUsPoints, (us) ->
            if us
                estimationProcess = $tgEstimationsService.create($el, us, $scope.project)

                # Update roles
                roles = estimationProcess.calculateRoles()
                if roles.length == 0
                    $el.find(".icon-arrow-bottom").remove()
                    $el.find("a.us-points").addClass("not-clickable")

                else if roles.length == 1
                    # Preselect the role if we have only one
                    selectedRoleId = _.keys(us.points)[0]

                if estimationProcess.isEditable
                    bindClickElements()

                estimationProcess.onSelectedPointForRole = (roleId, pointId, points) ->
                    us.points = points
                    estimationProcess.render()

                    @save(roleId, pointId).then ->
                        $ctrl.loadProjectStats()

                estimationProcess.render = () ->
                    totalPoints = @calculateTotalPoints()
                    if not selectedRoleId? or roles.length == 1
                        text = totalPoints
                        title = totalPoints
                    else
                        pointId = @us.points[selectedRoleId]
                        pointObj = @pointsById[pointId]
                        text = "#{pointObj.name} / <span>#{totalPoints}</span>"
                        title = "#{pointObj.name} / #{totalPoints}"

                    ctx = {
                        totalPoints: totalPoints
                        roles: @calculateRoles()
                        editable: @isEditable
                        text:  text
                        title: title
                    }
                    mainTemplate = "common/estimation/us-estimation-total.html"
                    template = $tgTemplate.get(mainTemplate, true)
                    html = template(ctx)
                    @$el.html(html)

                estimationProcess.render()

        renderRolesSelector = () ->
            roles = estimationProcess.calculateRoles()
            html = rolesTemplate({"roles": roles})
            # Render into DOM and show the new created element
            $el.append(html)
            $el.find(".pop-role").popover().open(() -> $(this).remove())

        bindClickElements = () ->
            $el.on "click", "a.us-points", (event) ->
                event.preventDefault()
                event.stopPropagation()
                us = $scope.$eval($attrs.tgBacklogUsPoints)
                updatingSelectedRoleId = selectedRoleId
                if selectedRoleId?
                    estimationProcess.renderPointsSelector(selectedRoleId)
                else
                    renderRolesSelector()

            $el.on "click", ".role", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                us = $scope.$eval($attrs.tgBacklogUsPoints)
                updatingSelectedRoleId = target.data("role-id")
                popRolesDom = $el.find(".pop-role")
                popRolesDom.find("a").removeClass("active")
                popRolesDom.find("a[data-role-id='#{updatingSelectedRoleId}']").addClass("active")
                estimationProcess.renderPointsSelector(updatingSelectedRoleId)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgBacklogUsPoints", ["$tgEstimationsService", "$tgRepo", "$tgTemplate", UsPointsDirective])


#############################################################################
## Burndown graph directive
#############################################################################
ToggleBurndownVisibility = ($storage) ->
    hide = () ->
        $(".js-burndown-graph").removeClass("shown")
        $(".js-toggle-burndown-visibility-button").removeClass("active")
        $(".js-burndown-graph").removeClass("open")

    show = (firstLoad) ->
        $(".js-toggle-burndown-visibility-button").addClass("active")

        if firstLoad
            $(".js-burndown-graph").addClass("shown")
        else
            $(".js-burndown-graph").addClass("open")

    link = ($scope, $el, $attrs) ->
        firstLoad = true
        hash = generateHash(["is-burndown-grpahs-collapsed"])
        $scope.isBurndownGraphCollapsed = $storage.get(hash) or false

        toggleGraph = ->
            if $scope.isBurndownGraphCollapsed
                hide(firstLoad)
            else
                show(firstLoad)

            firstLoad = false

        $scope.$watch "showGraphPlaceholder", () ->
            if $scope.showGraphPlaceholder?
                $scope.isBurndownGraphCollapsed = $scope.isBurndownGraphCollapsed || $scope.showGraphPlaceholder
                toggleGraph()

        $el.on "click", ".js-toggle-burndown-visibility-button", ->
            $scope.isBurndownGraphCollapsed = !$scope.isBurndownGraphCollapsed
            $storage.set(hash, $scope.isBurndownGraphCollapsed)
            toggleGraph()

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
    }

module.directive("tgToggleBurndownVisibility", ["$tgStorage", ToggleBurndownVisibility])


#############################################################################
## Burndown graph directive
#############################################################################

BurndownBacklogGraphDirective = ($translate) ->
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
        client_increment_line = _.map dataToDraw.milestones, (ml) ->
            -ml["team-increment"] - ml["client-increment"]
        data.push({
            data: _.zip(milestonesRange, client_increment_line)
            lines:
                fillColor : "rgba(255,51,51,0.3)"
        })
        team_increment_line = _.map(dataToDraw.milestones, (ml) -> -ml["team-increment"])
        data.push({
            data: _.zip(milestonesRange, team_increment_line)
            lines:
                fillColor : "rgba(153,51,51,0.3)"
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
                hoverable: true
            }
            xaxis: {
                ticks: dataToDraw.milestones.length
                axisLabel: $translate.instant("BACKLOG.CHART.XAXIS_LABEL"),
                axisLabelUseCanvas: true
                axisLabelFontSizePixels: 12
                axisLabelFontFamily: "Verdana, Arial, Helvetica, Tahoma, sans-serif"
                axisLabelPadding: 5
                tickFormatter: (val, axis) -> ""
            }
            yaxis: {
                axisLabel: $translate.instant("BACKLOG.CHART.YAXIS_LABEL"),
                axisLabelUseCanvas: true
                axisLabelFontSizePixels: 12
                axisLabelFontFamily: "Verdana, Arial, Helvetica, Tahoma, sans-serif"
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
            tooltip: true
            tooltipOpts: {
                content: (label, xval, yval, flotItem) ->
                    if flotItem.seriesIndex == 1
                        ctx = {sprintName: dataToDraw.milestones[xval].name, value: Math.abs(yval)}
                        return $translate.instant("BACKLOG.CHART.OPTIMAL", ctx)
                    else if flotItem.seriesIndex == 2
                        ctx = {sprintName: dataToDraw.milestones[xval].name, value: Math.abs(yval)}
                        return $translate.instant("BACKLOG.CHART.REAL", ctx)
                    else if flotItem.seriesIndex == 3
                        ctx = {sprintName: dataToDraw.milestones[xval].name, value: Math.abs(yval)}
                        return $translate.instant("BACKLOG.CHART.INCREMENT_CLIENT", ctx)
                    else
                        ctx = {sprintName: dataToDraw.milestones[xval].name, value: Math.abs(yval)}
                        return $translate.instant("BACKLOG.CHART.INCREMENT_TEAM", ctx)
            }
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

module.directive("tgBurndownBacklogGraph", ["$translate", BurndownBacklogGraphDirective])


#############################################################################
## Backlog progress bar directive
#############################################################################

TgBacklogProgressBarDirective = ($template, $compile) ->
    template = $template.get("backlog/progress-bar.html", true)

    render = (scope, el, projectPointsPercentaje, closedPointsPercentaje) ->
        html = template({
            projectPointsPercentaje: projectPointsPercentaje,
            closedPointsPercentaje:closedPointsPercentaje
        })
        html = $compile(html)(scope)
        el.html(html)

    adjustPercentaje = (percentage) ->
        adjusted = _.max([0 , percentage])
        adjusted = _.min([100, adjusted])
        return Math.round(adjusted)

    link = ($scope, $el, $attrs) ->
        element = angular.element($el)

        $scope.$watch $attrs.tgBacklogProgressBar, (stats) ->
            if stats?
                totalPoints = if stats.total_points then stats.total_points else stats.defined_points
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
                render($scope, $el, projectPointsPercentaje, closedPointsPercentaje)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgBacklogProgressBar", ["$tgTemplate", "$compile", TgBacklogProgressBarDirective])
