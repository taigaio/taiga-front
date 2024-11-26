###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

mixOf = @.taiga.mixOf
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
        "tgProjectService",
        "tgLoader"
    ]

    storeCustomFiltersName: 'backlog-custom-filters'
    storeFiltersName: 'backlog-filters'
    backlogOrder: {}
    milestonesOrder: {}
    newUs: []
    validQueryParams: [
        'exclude_status',
        'status',
        'exclude_tags',
        'tags',
        'exclude_assigned_users',
        'assigned_users',
        'exclude_role',
        'role',
        'exclude_epic',
        'epic',
        'exclude_owner',
        'owner'
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @appMetaService, @navUrls,
                  @events, @analytics, @translate, @loading, @rs2, @modelTransform, @errorHandlingService,
                  @storage, @filterRemoteStorageService, @projectService, @tgLoader) ->
        bindMethods(@)

        @.backlogOrder = {}
        @.milestonesOrder = {}

        @.page = 1
        @.disablePagination = false
        @.firstLoadComplete = false
        @.translationData = {q: @.filterQ}
        @scope.userstories = []
        @.totalUserStories = 0
        @.pendingDrag = []
        @scope.noSwimlaneUserStories = false
        @scope.swimlanesList = Immutable.List()

        return if @.applyStoredFilters(@params.pslug, "backlog-filters", @.validQueryParams)

        @scope.sectionName = @translate.instant("BACKLOG.SECTION_NAME")
        @showTags = true
        @activeFilters = false
        @scope.showGraphPlaceholder = null
        @displayVelocity = false

        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @.loadSwimlanes()
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

    preloadUsIds: () ->
        page = 1
        usIds = []

        loadNextPage = () =>
            lastLoadUserstoriesParams = Object.assign({}, @.lastLoadUserstoriesParams)

            params = Object.assign(lastLoadUserstoriesParams, {
                page: page
                only_ref: true
            })

            promise = @rs.userstories.listUnassigned(@scope.projectId, params, 100, false)
            promise.then (result) =>
                userstories = result[0]
                header = result[1]
                usIds = usIds.concat(userstories.map (us) => us.ref)
                @rs.userstories.storeBacklog(@scope.projectId, usIds)

                if header('x-pagination-next')
                    page++
                    loadNextPage()

        if @.disablePagination
            usIds = @scope.userstories.map (us) -> us.ref
            @rs.userstories.storeBacklog(@scope.projectId, usIds)
        else
            loadNextPage()

    filtersReloadContent: () ->
        @.loadUserstories(true)

    initializeEventHandlers: ->
        load = () =>
            @.loadUserstories(true)
            @.loadProjectStats()
            @rootscope.$broadcast("filters:update")

        @scope.$on "usform:bulk:success", (event, els, position = 'bottom') =>
            @.newUs = _.map els, (it) ->
                return it.id

            if position == 'top'
                @.moveUsToTopOfBacklog(els).then () =>
                    load()
            else
                load()

            @analytics.trackEvent("userstory", "create", "bulk create userstory on backlog", 1)

        @scope.$on "sprintform:create:success", (e, data, ussToMove) =>
            @.loadSprints().then () =>
                @scope.$broadcast("sprintform:create:success:callback", ussToMove)

            @.loadProjectStats()
            @confirm.notify("success")
            @analytics.trackEvent("sprint", "create", "create sprint on backlog", 1)

        @scope.$on "usform:new:success", (event, el, position = 'bottom') =>
            @.newUs = [el.id]

            if position == 'top'
                @.moveUsToTopOfBacklog(el).then () =>
                    load()
            else
                load()

            @analytics.trackEvent("userstory", "create", "create userstory on backlog", 1)

        @scope.$on "sprintform:edit:success", =>
            @.loadProjectStats()

        @scope.$on "sprintform:remove:success", (event, sprint) =>
            if @.displayVelocity
                @toggleVelocityForecasting()

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

        @scope.$on "filters:update", () => @.generateFilters(milestone = "null")

        @scope.$on("sprint:us:move", @.moveUs)
        @scope.$on "sprint:us:moved", () =>
            @.resetFirstStoryIndicator()
            @rootscope.$broadcast("filters:update")

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
            @.loadClosedSprints()
            @.loadProjectStats()
        , { selfNotification: true }

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
            @.calculateForecasting()
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

    loadSwimlanes: ->
        if (@scope.project.swimlanes)
            @scope.project.swimlanes.forEach (swimlane) =>
                if (!@scope.swimlanesList.includes(swimlane))
                    @scope.swimlanesList = @scope.swimlanesList.push(swimlane)

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
        return _.filter(@scope.sprints, (sprint) => not sprint.closed)

    loadAllPaginatedUserstories: () ->
        page = @.page

        @.loadUserstories(true, @scope.userstories.length).then () =>
          @.page = page

    loadUserstories: (resetPagination = false, pageSize) ->
        return null if !@scope.projectId

        @.loadingUserstories = true
        @.disablePagination = true
        params = _.pick(_.clone(@location.search()), @.validQueryParams)
        @rs.userstories.storeQueryParams(@scope.projectId, params)

        if resetPagination
            @.page = 1

        params.page = @.page
        params.q = @.filterQ

        @.lastLoadUserstoriesParams = params

        @.translationData.q = params.q

        promise = @rs.userstories.listUnassigned(@scope.projectId, params, pageSize)

        return promise.then (result) =>
            userstories = result[0]
            header = result[1]

            if resetPagination
                @scope.userstories = []

            uss = @.parseLoadUserstoriesResponse(userstories, header)

            if @.page <= 2
                @.preloadUsIds()

            return uss

    parseLoadUserstoriesResponse: (userstories, header) ->
        # NOTE: Fix order of USs because the filter orderBy does not work propertly in the partials files
        @scope.userstories = @scope.userstories.concat(_.sortBy(userstories, "backlog_order"))
        @.resetFirstStoryIndicator()
        @scope.visibleUserStories = _.map @scope.userstories, (it) ->
            return it.ref

        for it in @scope.userstories
            if @.newUs.includes(it.id)
                it.new = true

            @.backlogOrder[it.id] = it.backlog_order

        @.loadingUserstories = false

        if header('x-pagination-next')
            @.disablePagination = false
            @.page++

        if header('Taiga-Info-Backlog-Total-Userstories')
            @.totalUserStories = header('Taiga-Info-Backlog-Total-Userstories')

        if header('Taiga-Info-Userstories-Without-Swimlane')
            @scope.noSwimlaneUserStories = header('Taiga-Info-Userstories-Without-Swimlane')

        @rootscope.$broadcast("backlog:userstories:loaded")

        # The broadcast must be executed when the DOM has been fully reloaded.
        # We can't assure when this exactly happens so we need a defer
        scopeDefer @scope, =>
            @scope.$broadcast("userstories:loaded")
            @tgLoader.pageLoaded()

        return userstories

    loadBacklog: ->
        return @q.all([
            @.loadProjectStats(),
            @.loadSprints(),
            @.loadUserstories()
        ]).then(@.calculateForecasting)

    getLinkParams: () ->
        lastLoadUserstoriesParams = @.lastLoadUserstoriesParams

        if lastLoadUserstoriesParams
            delete lastLoadUserstoriesParams['page']

            lastLoadUserstoriesParams = _.pickBy(lastLoadUserstoriesParams, _.identity)

            ParsedLastLoadUserstoriesParams = {}
            Object.keys(lastLoadUserstoriesParams).forEach (key) ->
                ParsedLastLoadUserstoriesParams['backlog-' + key] = lastLoadUserstoriesParams[key]

            ParsedLastLoadUserstoriesParams['no-milestone'] = 1

            return ParsedLastLoadUserstoriesParams
        else
            return {}

    sprintTotalPoints: (sprint) ->
        points = 0

        for us in sprint.user_stories
            if us.milestone == sprint.id
                points += us.total_points

        return points

    calculateForecasting: ->
        stats = @scope.stats
        total_points = stats.total_points
        current_sum = stats.assigned_points
        backlog_points_sum = 0
        @forecastedStories = []
        @scope.forecastNewSprint = true

        if @scope.sprints && @scope.sprints.length
            backlog_points_sum = @.sprintTotalPoints(@scope.sprints[0])

            # set 0 bacause we're going to create a new sprint
            if stats.speed > 0 && backlog_points_sum > stats.speed
                backlog_points_sum = 0
            else
                @scope.forecastNewSprint = false

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

        @.resetFirstStoryIndicator()

        return project

    loadInitialData: ->
        project = @.loadProject()

        @.fillUsersAndRoles(project.members, project.roles)
        @.initializeSubscription()

        if @rs.userstories.getShowTags(@scope.projectId) == false
            @showTags = false

        return @.loadBacklog()
            .then(=> @.generateFilters(milestone = "null"))
            .then(=> @scope.$emit("backlog:loaded"))

    toggleTags: () ->
        @rs.userstories.storeShowTags(@scope.projectId, @showTags)

    prepareBulkUpdateData: (uses, field="backlog_order") ->
         return _.map(uses, (x) -> {"us_id": x.id, "order": x[field]})

    resetFirstStoryIndicator: () ->
      if @scope.userstories.length > 0
        @scope.first_us_in_backlog = @scope.userstories[0].id

    moveUsToTopOfBacklog: (uss) ->
        if !Array.isArray(uss)
            uss = [uss]

        us = uss[0]

        if @scope.userstories.length
            nextUs = @scope.userstories[0].id
            return @.moveUs("sprint:us:move", uss, 0, null, null, nextUs)

        return Promise.resolve()

    moveUs: (ctx, usList, newUsIndex, newSprintId, previousUs, nextUs) ->
        oldSprintId = usList[0].milestone
        project = usList[0].project

        if oldSprintId
            sprint = @scope.sprintsById[oldSprintId] || @scope.closedSprintsById[oldSprintId]

        if newSprintId
            newSprint = @scope.sprintsById[newSprintId] || @scope.closedSprintsById[newSprintId]

        currentSprintId = if newSprintId != oldSprintId then newSprintId else oldSprintId

        bulkUserstories = _.map(usList, (it) ->
            return it.id
        )

        if ctx
            @.pendingDrag.push({
                usList: usList,
                newUsIndex: newUsIndex,
                newSprintId: newSprintId,
                previousUs: previousUs,
                nextUs: nextUs
            })

            if newSprintId != oldSprintId
                if sprint
                    usList.forEach (us, index) =>
                        _.remove sprint.user_stories, (it) ->
                            return it.id == us.id

                if newSprintId == null # From sprint to backlog
                    for us, key in usList # delete from sprint userstories
                        _.remove sprint.user_stories, (it) -> it.id == us.id

                    usList.forEach (us, index) =>
                        @scope.userstories.splice(newUsIndex + index, 0, us)
                else
                    for us in usList # delete from backlog userstories
                        _.remove @scope.userstories, (it) -> it.id == us.id

                    usList.forEach (us, index) =>
                        us.milestone = newSprintId
                        newSprint.user_stories.splice(newUsIndex, 0, us)

                        newSprint = Object.assign(
                            newSprint,
                            {
                                user_stories: newSprint.user_stories.slice()
                            }
                        )

                        @scope.sprints = @scope.sprints.map (sprint) ->
                            return Object.assign(sprint)
            else
                if newSprintId # reorder in sprint
                    targetList = newSprint.user_stories
                else # reorder backlog
                    targetList = @scope.userstories

                for us in usList # delete from backlog userstories
                    _.remove targetList, (it) -> it.id == us.id

                position = 0

                if previousUs
                    position = targetList.findIndex (us) -> us.id == previousUs
                else if nextUs
                    position = targetList.findIndex (us) -> us.id == previousUs

                position++
                usList.forEach (us, index) =>
                    targetList.splice(position + index, 0, us)

            @scope.visibleUserStories = _.map @scope.userstories, (it) ->
                return it.ref

        if ctx && @.pendingDrag.length > 1
            return

        promise = @rs.userstories.bulkUpdateBacklogOrder(
            project,
            currentSprintId,
            previousUs,
            nextUs,
            bulkUserstories
        )

        promise.then (result) =>
            for updatedUs in result.data
                usList.forEach (us, index) =>
                    if us.id == updatedUs.id
                        us.milestone = updatedUs.milestone
                        us.backlog_order = updatedUs.backlog_order

            @.pendingDrag.shift()

            if @.pendingDrag.length
                @scope.$applyAsync () =>
                    @.moveUs(
                        null
                        @.pendingDrag[0].usList,
                        @.pendingDrag[0].newUsIndex,
                        @.pendingDrag[0].newSprintId,
                        @.pendingDrag[0].previousUs,
                        @.pendingDrag[0].nextUs,
                    )
            else
                @rootscope.$broadcast("sprint:us:moved")

                # taiga events will refresh the backlog if it's available
                if !@events.connected
                    @.loadSprints()
                    @.loadClosedSprints()
                    @.loadProjectStats()

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
        return @rs.userstories.getByRef(projectId, ref).then (us) =>
            @rs2.attachments.list("us", us.id, projectId).then (attachments) =>
                @rootscope.$broadcast("genericform:edit", {
                    'objType': 'us',
                    'obj': us,
                    'attachments': attachments.toJS()
                })

    deleteUserStory: (us) ->
        title = @translate.instant("US.TITLE_DELETE_ACTION",  {projectName: @scope.project.name})

        message = @translate.instant("US.TITLE_DELETE_MESSAGE",  {subject: us.subject})

        @confirm.askOnDelete(title, message, '').then (askResponse) =>
            # We modify the userstories in scope so the user doesn't see the removed US for a while
            @scope.userstories = _.without(@scope.userstories, us)
            promise = @.repo.remove(us)
            promise.then =>
                askResponse.finish()

                @q.all([
                    @.loadProjectStats(),
                    @.loadSprints(),
                    @.resetFirstStoryIndicator()
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

    addFilterBacklog: (newFilter) ->
        @.selectFilter(newFilter.category.dataType, newFilter.filter.id, false, newFilter.mode)
        @.filtersReloadContent()
        @.generateFilters('null')

    removeFilterBacklog: (filter) ->
        @.unselectFilter(filter.dataType, filter.id, false, filter.mode)
        @.filtersReloadContent()
        @.generateFilters('null')

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
        $scope.$on("sprint:us:moved", reloadDoomLine)
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
            sprint = if $scope.currentSprint then $scope.currentSprint else $scope.sprints[0]

            moveUssToSprint(selectedUss, sprint)

        moveToLatestSprint = (selectedUss) ->
            moveUssToSprint(selectedUss, $scope.sprints[0])

        $scope.$on "sprintform:create:success:callback", (e, ussToMove) ->
            if ussToMove
                _.partial(moveToCurrentSprint, ussToMove)()

        shiftPressed = false
        lastChecked = null

        checkSelected = (target) ->
            lastChecked = target.closest(".us-item-row")
            target.closest('.us-item-row').toggleClass('ui-multisortable-multiple')
            moveToSprintDom = $el.find(".move-to-sprint")
            selectedUsDom = $el.find(".backlog-table-body input:checkbox:checked")

            if selectedUsDom.length > 0 and $scope.sprints.length > 0
                moveToSprintDom.css('display', 'flex')
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

        $el.on "change", "#show-tags > input", (event) ->
            event.preventDefault()

            $ctrl.toggleShowTags()

            showHideTags($ctrl)

        $el.on "click", ".forecasting-add-sprint", (event) ->
            ussToMoveList = $ctrl.forecastedStories

            if !$scope.forecastNewSprint
                ussToMove = _.map ussToMoveList, (us, index) ->
                    us.milestone = $scope.sprints[0].id
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

            # text = $translate.instant("BACKLOG.TAGS.HIDE")
            # elm.text(text)
        else
            elm.removeClass("active")

            # text = $translate.instant("BACKLOG.TAGS.SHOW")
            # elm.text(text)

    openFilterInit = ($scope, $el, $ctrl) ->
        sidebar = $el.find(".backlog-filter")

        sidebar.addClass("active")

        $ctrl.activeFilters = true

    showHideFilter = ($scope, $el, $ctrl) ->
        filter = $el.find(".backlog-filter")

        target = angular.element("#show-filters-button")

        filter.toggleClass("active")
        target.toggleClass("active")

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
## User story edit directive
#############################################################################

UsEditSelector = ($rootscope, $tgTemplate, $compile, $translate) ->
    mainTemplate = $tgTemplate.get("backlog/us-edit-popover.html", true)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        removePopupOpenState = () ->
            $el.find(".js-popup-button").removeClass('popover-open')
            $(this).remove()

        $el.on "click", (event) ->
            html = $compile(mainTemplate())($scope)
            $el.find(".js-popup-button").addClass('popover-open')
            $el.append(html)
            $el.find(".us-option-popup").popover().open(() -> removePopupOpenState())
            if event.target.parentNode.classList.contains('first')
              $el.find(".us-option-popup").addClass('first')

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgUsEditSelector", ["$rootScope", "$tgTemplate", "$compile", "$translate", UsEditSelector])

#############################################################################
## User story points directive
#############################################################################

UsRolePointsSelectorDirective = ($rootscope, $template, $compile, $translate) ->
    selectionTemplate = $template.get("backlog/us-role-points-popover.html", true)

    link = ($scope, $el, $attrs) ->
        removePopupOpenState = () ->
            $el.removeClass('popover-open')

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
            $el.find(".header-points").html("#{roleName}")

        $scope.$on "uspoints:clear-selection", (ctx, roleId) ->
            $el.find(".popover").popover().close()

            text = $translate.instant("COMMON.FIELDS.POINTS")
            $el.find(".header-points").text(text)

        # Dom Event Handlers
        $el.on "click", (event) ->
            target = angular.element(event.target)

            if target.is("span") or target.is("div")
                event.stopPropagation()

            $el.addClass('popover-open')
            $el.find(".popover").popover().open(() -> removePopupOpenState())

        $el.on "click", ".clear-selection", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $rootscope.$broadcast("uspoints:clear-selection")
            $el.find('.active-popover').removeClass('active-popover')
            target.addClass('active-popover')

        $el.on "click", ".role", (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            $el.find('.active-popover').removeClass('active-popover')
            target.addClass('active-popover')
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
            $el.on "click", ".us-points", (event) ->
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
                fillColor : "rgba(200,201,196,0.2)"
        })
        evolution_line = _.filter(_.map(dataToDraw.milestones, (ml) -> ml.evolution), (evolution) -> evolution?)
        data.push({
            data: _.zip(milestonesRange, evolution_line)
            lines:
                fillColor : "rgba(147,196,0,0.2)"
        })
        client_increment_line = _.map dataToDraw.milestones, (ml) ->
            -ml["team-increment"] - ml["client-increment"]
        data.push({
            data: _.zip(milestonesRange, client_increment_line)
            lines:
                fillColor : "rgba(200,201,196,0.2)"
        })
        team_increment_line = _.map(dataToDraw.milestones, (ml) -> -ml["team-increment"])
        data.push({
            data: _.zip(milestonesRange, team_increment_line)
            lines:
                fillColor : "rgba(255,160,160,0.2)"
        })
        colors = [
            "rgba(200,201,196,0.2)"
            "rgba(216,222,233,1)"
            "rgba(168,228,64,1)"
            "rgba(216,222,233,1)"
            "rgba(255,160,160,1)"
        ]

        options = {
            grid: {
                borderWidth: { top: 0, right: 1, left:0, bottom: 0 }
                borderColor: "#D8DEE9"
                color: "#D8DEE9"
                hoverable: true
                margin: { top: 0, right: 20, left: 5, bottom: 0 }
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
                        ctx = {sprintName: dataToDraw.milestones[xval].name, value: Math.abs(yval * 10) / 10}
                        return $translate.instant("BACKLOG.CHART.OPTIMAL", ctx)
                    else if flotItem.seriesIndex == 2
                        ctx = {sprintName: dataToDraw.milestones[xval].name, value: Math.abs(yval * 10) / 10}
                        return $translate.instant("BACKLOG.CHART.REAL", ctx)
                    else if flotItem.seriesIndex == 3
                        ctx = {sprintName: dataToDraw.milestones[xval].name, value: Math.abs(yval * 10) / 10}
                        return $translate.instant("BACKLOG.CHART.INCREMENT_CLIENT", ctx)
                    else
                        ctx = {sprintName: dataToDraw.milestones[xval].name, value: Math.abs(yval * 10) / 10}
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
