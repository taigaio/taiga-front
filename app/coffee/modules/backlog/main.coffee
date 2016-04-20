###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
        "tgAppMetaService",
        "$tgNavUrls",
        "$tgEvents",
        "$tgAnalytics",
        "$translate",
        "$tgLoading",
        "tgResources"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q,
                  @location, @appMetaService, @navUrls, @events, @analytics, @translate, @loading, @rs2) ->
        bindMethods(@)

        @.page = 1
        @.disablePagination = false
        @scope.userstories = []

        @scope.sectionName = @translate.instant("BACKLOG.SECTION_NAME")
        @showTags = false
        @activeFilters = false
        @scope.showGraphPlaceholder = null

        @.initializeEventHandlers()

        promise = @.loadInitialData()

        # On Success
        promise.then =>
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

    resetBacklogPagination: ->
        @.page = 1
        @scope.userstories = []

    initializeEventHandlers: ->
        @scope.$on "usform:bulk:success", =>
            @.resetBacklogPagination()
            @.loadUserstories()
            @.loadProjectStats()
            @analytics.trackEvent("userstory", "create", "bulk create userstory on backlog", 1)

        @scope.$on "sprintform:create:success", =>
            @.loadSprints()
            @.loadProjectStats()
            @analytics.trackEvent("sprint", "create", "create sprint on backlog", 1)

        @scope.$on "usform:new:success", =>
            @.resetBacklogPagination()
            @.loadUserstories()
            @.loadProjectStats()

            @rootscope.$broadcast("filters:update")
            @analytics.trackEvent("userstory", "create", "create userstory on backlog", 1)

        @scope.$on "sprintform:edit:success", =>
            @.loadProjectStats()

        @scope.$on "sprintform:remove:success", (event, sprint) =>
            @.resetBacklogPagination()
            @.loadSprints()
            @.loadProjectStats()
            @.loadUserstories()

            if sprint.closed
                @.loadClosedSprints()

            @rootscope.$broadcast("filters:update")

        @scope.$on "usform:edit:success", (event, data) =>
            index = _.findIndex @scope.userstories, (us) ->
                return us.id == data.id

            @scope.userstories[index] = data

            @rootscope.$broadcast("filters:update")

        @scope.$on("sprint:us:move", @.moveUs)
        @scope.$on("sprint:us:moved", @.loadSprints)
        @scope.$on("sprint:us:moved", @.loadProjectStats)

        @scope.$on("backlog:load-closed-sprints", @.loadClosedSprints)
        @scope.$on("backlog:unload-closed-sprints", @.unloadClosedSprints)

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
            totalPoints = if stats.total_points then stats.total_points else stats.defined_points

            if totalPoints
                @scope.stats.completedPercentage = Math.round(100 * stats.closed_points / totalPoints)
            else
                @scope.stats.completedPercentage = 0

            @scope.showGraphPlaceholder = !(stats.total_points? && stats.total_milestones?)
            return stats

    unloadClosedSprints: ->
        @scope.$apply =>
            @scope.closedSprints =  []
            @rootscope.$broadcast("closed-sprints:reloaded", [])

    loadClosedSprints: ->
        params = {closed: true}
        return @rs.sprints.list(@scope.projectId, params).then (result) =>
            sprints = result.milestones

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

            @scope.totalMilestones = sprints
            @scope.totalClosedMilestones = result.closed
            @scope.totalOpenMilestones = result.open
            @scope.totalMilestones = @scope.totalOpenMilestones + @scope.totalClosedMilestones

            # NOTE: Fix order of USs because the filter orderBy does not work propertly in partials files
            for sprint in sprints
                sprint.user_stories = _.sortBy(sprint.user_stories, "sprint_order")

            @scope.sprints = sprints
            @scope.openSprints = _.filter(sprints, (sprint) => not sprint.closed).reverse()
            @scope.closedSprints =  [] if !@scope.closedSprints

            @scope.sprintsCounter = sprints.length
            @scope.sprintsById = groupBy(sprints, (x) -> x.id)
            @rootscope.$broadcast("sprints:loaded", sprints)

            @scope.currentSprint = @.findCurrentSprint()

            return sprints

    restoreFilters: ->
        selectedTags = @scope.oldSelectedTags
        selectedStatuses = @scope.oldSelectedStatuses

        return if !selectedStatuses and !selectedStatuses

        @scope.filtersQ = @scope.filtersQOld

        @.replaceFilter("q", @scope.filtersQ)

        _.each [selectedTags, selectedStatuses], (filterGrp) =>
            _.each filterGrp, (item) =>
                filters = @scope.filters[item.type]
                filter = _.find(filters, {id: item.id})
                filter.selected = true

                @.selectFilter(item.type, item.id)

        @.loadUserstories()

    resetFilters: ->
        selectedTags = _.filter(@scope.filters.tags, "selected")
        selectedStatuses = _.filter(@scope.filters.status, "selected")

        @scope.oldSelectedTags = selectedTags
        @scope.oldSelectedStatuses = selectedStatuses

        @scope.filtersQOld = @scope.filtersQ
        @scope.filtersQ = undefined
        @.replaceFilter("q", @scope.filtersQ)

        _.each [selectedTags, selectedStatuses], (filterGrp) =>
            _.each filterGrp, (item) =>
                filters = @scope.filters[item.type]
                filter = _.find(filters, {id: item.id})
                filter.selected = false

                @.unselectFilter(item.type, item.id)

        @.loadUserstories()

    loadUserstories: ->
        @.loadingUserstories = true
        @.disablePagination = true
        @scope.httpParams = @.getUrlFilters()
        @rs.userstories.storeQueryParams(@scope.projectId, @scope.httpParams)

        @scope.httpParams.page = @.page

        promise = @rs.userstories.listUnassigned(@scope.projectId, @scope.httpParams)

        return promise.then (result) =>
            userstories = result[0]
            header = result[1]

            # NOTE: Fix order of USs because the filter orderBy does not work propertly in the partials files
            @scope.userstories = @scope.userstories.concat(_.sortBy(userstories, "backlog_order"))

            @.setSearchDataFilters()

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
        ])

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            if not project.is_backlog_activated
                @location.path(@navUrls.resolve("permission-denied"))

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
        promise = @.loadProject()
        promise.then (project) =>
            @.fillUsersAndRoles(project.members, project.roles)
            @.initializeSubscription()

        return promise
            .then(=> @.loadBacklog())
            .then(=> @.generateFilters())
            .then(=> @scope.$emit("backlog:loaded"))

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

        movedFromClosedSprint = false
        movedToClosedSprint = false

        sprint = @scope.sprintsById[oldSprintId]

        # Move from closed sprint
        if !sprint && @scope.closedSprintsById
            sprint = @scope.closedSprintsById[oldSprintId]
            movedFromClosedSprint = true if sprint

        newSprint = @scope.sprintsById[newSprintId]

        # Move to closed sprint
        if !newSprint && newSprintId
            newSprint = @scope.closedSprintsById[newSprintId]
            movedToClosedSprint = true if newSprint

        # In the same sprint or in the backlog
        if newSprintId == oldSprintId
            items = null
            userstories = null

            if newSprintId == null
                userstories = @scope.userstories
            else
                userstories = newSprint.user_stories

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
                args = [newUsIndex, 0].concat(usList)
                Array.prototype.splice.apply(@scope.userstories, args)

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

                    if movedFromClosedSprint
                        @rootscope.$broadcast("backlog:load-closed-sprints")

            promise.then null, ->
                console.log "FAIL" # TODO

            return promise

        # From backlog to sprint
        if oldSprintId == null
            us.milestone = newSprintId for us in usList

            @scope.$apply =>
                args = [newUsIndex, 0].concat(usList)

                # Add moving us to sprint user stories list
                Array.prototype.splice.apply(newSprint.user_stories, args)

                # Remove moving us from backlog userstories lists.
                for us, key in usList
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
                    r = sprint.user_stories.indexOf(us)
                    sprint.user_stories.splice(r, 1)

        # Persist the milestone change of userstory
        promises = _.map usList, (us) => @repo.save(us)

        # Rehash userstories order field
        # and persist in bulk all changes.
        promise = @q.all(promises).then =>
            items = @.resortUserStories(newSprint.user_stories, "sprint_order")
            data = @.prepareBulkUpdateData(items, "sprint_order")

            @rs.userstories.bulkUpdateSprintOrder(project, data).then (result) =>
                @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

            @rs.userstories.bulkUpdateBacklogOrder(project, data).then =>
                for us in usList
                    @rootscope.$broadcast("sprint:us:moved", us, oldSprintId, newSprintId)

            if movedToClosedSprint || movedFromClosedSprint
                @scope.$broadcast("backlog:load-closed-sprints")

        promise.then null, ->
            console.log "FAIL" # TODO

        return promise

    isFilterSelected: (type, id) ->
        if @searchdata[type]? and @searchdata[type][id]
            return true
        return false

    setSearchDataFilters: () ->
        urlfilters = @.getUrlFilters()

        if urlfilters.q
            @scope.filtersQ = @scope.filtersQ or urlfilters.q

        @searchdata = {}
        for name, value of urlfilters
            if not @searchdata[name]?
                @searchdata[name] = {}

            for val in taiga.toString(value).split(",")
                @searchdata[name][val] = true

    getUrlFilters: ->
        return _.pick(@location.search(), "status", "tags", "q")

    generateFilters: ->
        urlfilters = @.getUrlFilters()
        @scope.filters =  {}

        loadFilters = {}
        loadFilters.project = @scope.projectId
        loadFilters.tags = urlfilters.tags
        loadFilters.status = urlfilters.status
        loadFilters.q = urlfilters.q
        loadFilters.milestone = 'null'

        return @rs.userstories.filtersData(loadFilters).then (data) =>
            choicesFiltersFormat = (choices, type, byIdObject) =>
                _.map choices, (t) ->
                    t.type = type
                    return t

            tagsFilterFormat = (tags) =>
                return _.map tags, (t) ->
                    t.id = t.name
                    t.type = 'tags'
                    return t

            # Build filters data structure
            @scope.filters.status = choicesFiltersFormat(data.statuses, "status", @scope.usStatusById)
            @scope.filters.tags = tagsFilterFormat(data.tags)

            selectedTags = _.filter(@scope.filters.tags, "selected")
            selectedTags = _.map(selectedTags, "id")

            selectedStatuses = _.filter(@scope.filters.status, "selected")
            selectedStatuses = _.map(selectedStatuses, "id")

            @.markSelectedFilters(@scope.filters, urlfilters)

            #store query params
            @rs.userstories.storeQueryParams(@scope.projectId, {
                "status": selectedStatuses,
                "tags": selectedTags,
                "project": @scope.projectId
                "milestone": null
            })

    markSelectedFilters: (filters, urlfilters) ->
        # Build selected filters (from url) fast lookup data structure
        searchdata = {}
        for name, value of _.omit(urlfilters, "page", "orderBy")
            if not searchdata[name]?
                searchdata[name] = {}

            for val in "#{value}".split(",")
                searchdata[name][val] = true

        isSelected = (type, id) ->
            if searchdata[type]? and searchdata[type][id]
                return true
            return false

        for key, value of filters
            for obj in value
                obj.selected = if isSelected(obj.type, obj.id) then true else undefined

    ## Template actions

    updateUserStoryStatus: () ->
        @.setSearchDataFilters()
        @.generateFilters().then () =>
            @rootscope.$broadcast("filters:update")
            @.loadProjectStats()

    editUserStory: (projectId, ref, $event) ->
        target = $($event.target)

        currentLoading = @loading()
            .target(target)
            .removeClasses("edit-story")
            .timeout(200)
            .start()

        return @rs.userstories.getByRef(projectId, ref).then (us) =>
            @rs2.attachments.list("us", us.id, projectId).then (attachments) =>
                @rootscope.$broadcast("usform:edit", us, attachments.toJS())
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
                @.loadBacklog()
            promise.then null, =>
                askResponse.finish(false)
                @confirm.notify("error")

    addNewUs: (type) ->
        switch type
            when "standard" then @rootscope.$broadcast("usform:new", @scope.projectId,
                                                       @scope.project.default_us_status, @scope.usStatusList)
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

BacklogDirective = ($repo, $rootscope, $translate) ->
    ## Doom line Link
    doomLineTemplate = _.template("""
    <div class="doom-line"><span><%- text %></span></div>
    """)

    linkDoomLine = ($scope, $el, $attrs, $ctrl) ->
        reloadDoomLine = ->
            if $scope.stats? and $scope.stats.total_points? and $scope.stats.total_points != 0
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
        $scope.$watch "stats", reloadDoomLine

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

            $repo.saveAll(selectedUss).then ->
                $ctrl.loadSprints()
                $ctrl.loadProjectStats()

            $el.find(".move-to-sprint").hide()

        moveToCurrentSprint = (selectedUss) ->
            moveUssToSprint(selectedUss, $scope.currentSprint)

        moveToLatestSprint = (selectedUss) ->
            moveUssToSprint(selectedUss, $scope.sprints[0])

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

        hideText = $translate.instant("BACKLOG.FILTERS.HIDE")
        showText = $translate.instant("BACKLOG.FILTERS.SHOW")

        toggleText(target, [hideText, showText])

        if !sidebar.hasClass("active")
            $ctrl.resetFilters()
        else
            $ctrl.restoreFilters()

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
        if filters.status ||
           filters.tags ||
           filters.q
            showHideFilter($scope, $el, $ctrl)

        $scope.$on "showTags", () ->
            showHideTags($ctrl)

        $scope.$on "$destroy", ->
            $el.off()
            $(window).off(".shift-pressed")

    return {link: link}


module.directive("tgBacklog", ["$tgRepo", "$rootScope", "$translate", BacklogDirective])

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
                $el.find(".icon-arrow-bottom").remove()
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

                estimationProcess.onSelectedPointForRole = (roleId, pointId) ->
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
