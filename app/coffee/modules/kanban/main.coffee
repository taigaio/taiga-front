###
# Copyright (C) 2014-present Taiga Agile LLC
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
debounceLeading = @.taiga.debounceLeading

module = angular.module("taigaKanban")

#############################################################################
## Kanban Controller
#############################################################################

class KanbanController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin, taiga.UsFiltersMixin)
    excludeFilters: [
        "status"
    ]

    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "tgAppMetaService",
        "$tgNavUrls",
        "$tgEvents",
        "$tgAnalytics",
        "$translate",
        "tgErrorHandlingService",
        "$tgModel",
        "tgKanbanUserstories",
        "$tgStorage",
        "tgFilterRemoteStorageService",
        "tgProjectService",
        "tgLightboxFactory",
        "tgLoader",
        "$timeout"
    ]

    storeCustomFiltersName: 'kanban-custom-filters'
    storeFiltersName: 'kanban-filters'

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @rs2, @params, @q, @location,
                  @appMetaService, @navUrls, @events, @analytics, @translate, @errorHandlingService,
                  @model, @kanbanUserstoriesService, @storage, @filterRemoteStorageService,
                  @projectService, @lightboxFactory, @tgLoader, @timeout) ->
        bindMethods(@)
        @kanbanUserstoriesService.reset()
        @.openFilter = false
        @.selectedUss = {}
        @.foldedSwimlane = Immutable.Map()
        @.isFirstLoad = true
        @.renderBatching = true

        @.isLightboxOpened = false # True when a lighbox is open
        @.isRefreshNeeded = false  # True if a lighbox is open and some event arrived

        return if @.applyStoredFilters(@params.pslug, "kanban-filters")

        @scope.sectionName = @translate.instant("KANBAN.SECTION_NAME")
        @.initializeEventHandlers()

        taiga.defineImmutableProperty @.scope, "usByStatus", () =>
            return @kanbanUserstoriesService.usByStatus

        taiga.defineImmutableProperty @.scope, "usMap", () =>
            return @kanbanUserstoriesService.usMap

        taiga.defineImmutableProperty @.scope, "usByStatusSwimlanes", () =>
            return @kanbanUserstoriesService.usByStatusSwimlanes

        taiga.defineImmutableProperty @.scope, "swimlanesList", () =>
            return @kanbanUserstoriesService.swimlanesList

    cleanSelectedUss: () ->
        for key of @.selectedUss
            @.selectedUss[key] = false

    toggleSelectedUs: (usId) ->
        @.selectedUss[usId] = !@.selectedUss[usId]

    firstLoad: () ->
        promise = @.loadInitialData()

        # On Success
        promise.then =>
            title = @translate.instant("KANBAN.PAGE_TITLE", {projectName: @scope.project.name})
            description = @translate.instant("KANBAN.PAGE_DESCRIPTION", {
                projectName: @scope.project.name,
                projectDescription: @scope.project.description
            })
            @appMetaService.setAll(title, description)

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    setZoom: (zoomLevel, zoom) ->
        zoomLevel = Number(zoomLevel)
        if @.zoomLevel == zoomLevel
            return null

        previousZoomLevel = @.zoomLevel

        @.zoomLevel = zoomLevel
        @.zoom = zoom

        if @.isFirstLoad
            @.firstLoad().then () =>
                @.isFirstLoad = false
                @kanbanUserstoriesService.resetFolds()

        else if @.zoomLevel > 2 && previousZoomLevel <= 2
            @.zoomLoading = true

            @.loadUserstories().then () =>
                @.zoomLoading = false
                @kanbanUserstoriesService.resetFolds()

    filtersReloadContent: () ->
        @.loadUserstories().then (result) =>
            if @scope.swimlanesList.size && !result.length
                @.foldedSwimlane = @.foldedSwimlane.set(@scope.swimlanesList.first().id.toString(), false)

            openArchived = _.difference(@kanbanUserstoriesService.archivedStatus,
                                        @kanbanUserstoriesService.statusHide)
            if openArchived.length
                for statusId in openArchived
                    @.loadUserStoriesForStatus({}, statusId)

    initializeEventHandlers: ->
        @scope.$on "usform:new:success", (event, us) =>
            @.refreshTagsColors().then () =>
                @kanbanUserstoriesService.add(us)
                @scope.$broadcast("redraw:wip")

            @analytics.trackEvent("userstory", "create", "create userstory on kanban", 1)

        @scope.$on "usform:bulk:success", (event, uss) =>
            @confirm.notify("success")
            @.refreshTagsColors().then () =>
                @kanbanUserstoriesService.add(uss)
                @scope.$broadcast("redraw:wip")

            @analytics.trackEvent("userstory", "create", "bulk create userstory on kanban", 1)

        @scope.$on "usform:edit:success", (event, us) =>
            @.refreshTagsColors().then () =>
                oldStatus = @kanbanUserstoriesService.getUsModel(us.id).status
                if oldStatus != us.status
                    # the us has to move at the end of the status
                    status = @scope.usByStatus.get(us.status.toString())
                    if status
                        lastUsId = status.last()
                        newOrder = @scope.usMap.get(lastUsId).getIn(['model', 'kanban_order']) + 1
                        us.kanban_order = newOrder

                @kanbanUserstoriesService.replaceModel(us)
                @kanbanUserstoriesService.refreshRawOrder()
                @kanbanUserstoriesService.refresh(false)

        @scope.$on "kanban:us:deleted", (event, us) =>
            @.filtersReloadContent()
            @kanbanUserstoriesService.refreshSwimlanes()

        @scope.$on("kanban:us:move", @.moveUs)
        @scope.$on("kanban:show-userstories-for-status", @.loadUserStoriesForStatus)
        @scope.$on("kanban:hide-userstories-for-status", @.hideUserStoriesForStatus)

        @scope.$on "lightbox:opened", () =>
            @.isLightboxOpened = true

        @scope.$on "lightbox:closed", () =>
            @.isLightboxOpened = false
            if @.isRefreshNeeded
                @.refreshAfterSwimlanesOrUserstoryStatusesHaveChanged()
                @.isRefreshNeeded = false

    refreshAfterSwimlanesOrUserstoryStatusesHaveChanged: ->
        # User story statuses has changed
        @tgLoader.start()
        @projectService.fetchProject().then () =>
            @.loadInitialData()

    initializeSubscription: ->
        randomTimeout = taiga.randomInt(700, 1000)

        # For user stories events
        routingKeyUserstories = "changes.project.#{@scope.projectId}.userstories"
        @events.subscribe @scope, routingKeyUserstories, debounceLeading randomTimeout, (message) =>
            @.loadUserstories()

        # For project attributes (swimlanes, statuses,...) events
        routingKeyProject = "changes.project.#{@scope.projectId}.projects"
        @events.subscribe @scope, routingKeyProject, debounceLeading randomTimeout, (message) =>
            if message.matches in [
                "projects.swimlane"
                "projects.swimlaneuserstorystatus"
                "projects.userstorystatus"
            ]
                if @.isLightboxOpened
                    @.isRefreshNeeded = true
                else
                    @.refreshAfterSwimlanesOrUserstoryStatusesHaveChanged()

    addNewUs: (type, statusId) ->
        swimlane = null
        switch type
            when "standard" then  @rootscope.$broadcast("genericform:new",
                {
                    'objType': 'us',
                    'project': @scope.project,
                    'statusId': statusId,
                    'swimlane': swimlane
                })
            when "bulk" then @rootscope.$broadcast("usform:bulk", @scope.projectId, statusId, swimlane)

    editUs: (id) ->
        us = @kanbanUserstoriesService.getUs(id)
        us = us.set('loading-edit', true)
        @kanbanUserstoriesService.replace(us)

        @rs.userstories.getByRef(us.getIn(['model', 'project']), us.getIn(['model', 'ref']))
        .then (editingUserStory) =>
            @rs2.attachments.list(
                "us", us.get('id'), us.getIn(['model', 'project'])).then (attachments) =>
                    @rootscope.$broadcast("genericform:edit", {
                        'objType': 'us',
                        'obj': editingUserStory,
                        'statusList': @scope.usStatusList,
                        'attachments': attachments.toJS()
                    })

                us = us.set('loading-edit', false)
                @kanbanUserstoriesService.replace(us)

    deleteUs: (id) ->
        us = @kanbanUserstoriesService.getUs(id)
        us = us.set('loading-delete', true)

        @rs.userstories.getByRef(us.getIn(['model', 'project']), us.getIn(['model', 'ref']))
        .then (deletingUserStory) =>
            us = us.set('loading-delete', false)
            title = @translate.instant("US.TITLE_DELETE_ACTION")
            message = deletingUserStory.subject
            @confirm.askOnDelete(title, message).then (askResponse) =>
                promise = @repo.remove(deletingUserStory)
                promise.then =>
                    @scope.$broadcast("kanban:us:deleted")
                    askResponse.finish()
                promise.then null, ->
                    askResponse.finish(false)
                    @confirm.notify("error")

    showPlaceHolder: (statusId, swimlaneId) ->
        firstStatus = @scope.usStatusList[0].id == statusId && !@kanbanUserstoriesService.userstoriesRaw.length

        if swimlaneId
            firstSwimlane =  @scope.swimlanesList.first().id == swimlaneId
            return firstStatus && firstSwimlane

        return firstStatus

    toggleFold: (id) ->
        @kanbanUserstoriesService.toggleFold(id)

    toggleSwimlane: (id) ->
        @.foldedSwimlane = @.foldedSwimlane.set(id.toString(), !@.foldedSwimlane.get(id.toString()))
        @rs.kanban.storeSwimlanesModes(@scope.projectId, @.foldedSwimlane.toJS())

        @timeout () =>
            @scope.$broadcast("redraw:wip")
        , 100, false

    isUsInArchivedHiddenStatus: (usId) ->
        return @kanbanUserstoriesService.isUsInArchivedHiddenStatus(usId)

    changeUsAssignedUsers: (id) =>
        item = @kanbanUserstoriesService.getUsModel(id)

        onClose = (assignedUsersIds) =>
            item.assigned_users = assignedUsersIds
            if item.assigned_to not in assignedUsersIds and assignedUsersIds.length > 0
                item.assigned_to = assignedUsersIds[0]
            if assignedUsersIds.length == 0
                item.assigned_to = null
            @kanbanUserstoriesService.replaceModel(item)

            @repo.save(item).then =>
                @.generateFilters()
                if @.isFilterDataTypeSelected('assigned_users') || @.isFilterDataTypeSelected('role')
                    @.filtersReloadContent()

        @lightboxFactory.create(
            'tg-lb-select-user',
            {
                "class": "lightbox lightbox-select-user",
            },
            {
                "currentUsers": _.compact(_.union(item.assigned_users, [item.assigned_to])),
                "activeUsers": @scope.activeUsers,
                "onClose": onClose,
                "lbTitle": @translate.instant("COMMON.ASSIGNED_USERS.ADD"),
            }
        )

    refreshTagsColors: ->
        return @rs.projects.tagsColors(@scope.projectId).then (tags_colors) =>
            @scope.project.tags_colors = tags_colors._attrs

    renderBatch: (clean = false) ->
        newUs = _.take(@.queue, @.batchSize)
        @.rendered = _.concat(@.rendered, newUs)
        @.queue = _.drop(@.queue, @.batchSize)

        if clean
            @kanbanUserstoriesService.set(newUs)
        else
            @kanbanUserstoriesService.add(newUs)

        if @.queue.length > 0
            @timeout(@.renderBatch)
        else
            scopeDefer @scope, =>
                # The broadcast must be executed when the DOM has been fully reloaded.
                # We can't assure when this exactly happens so we need a defer
                @rootscope.$broadcast("kanban:userstories:loaded", @.rendered)
                @scope.$broadcast("userstories:loaded", @.rendered)

                @timeout () =>
                    @scope.$broadcast("redraw:wip")
                , 100, false

    renderUserStories: (userstories) =>
        userstories = _.sortBy(userstories, 'kanban_order')
        # init before render is needed in KanbanSquishColumnDirective to
        # render status columns if not we will see the column squash on load
        @kanbanUserstoriesService.initUsByStatusList(userstories)

        if @.renderBatching
            userstoriesMap = _.groupBy(userstories, 'status')
            @.rendered = []
            @.queue = []
            @.batchSize = 0

            while (@.queue.length < userstories.length)
                _.each @scope.project.us_statuses, (x) =>
                    if (userstoriesMap[x.id]?.length > 0)
                        @.queue = _.concat(@.queue, _.take(userstoriesMap[x.id], 10))
                        userstoriesMap[x.id] = _.drop(userstoriesMap[x.id], 10)
                if !@.batchSize
                    @.batchSize = @.queue.length

            @.renderBatch(true)
        else
            @kanbanUserstoriesService.set(userstories)

    loadUserstories: () ->
        params = {
            status__is_archived: false
        }

        if @.zoomLevel >= 2
            params.include_attachments = 1
            params.include_tasks = 1

        params = _.merge params, @location.search()
        params.q = @.filterQ

        promise = @q.all([
            @rs.userstories.listAll(@scope.projectId, params),
            @.loadSwimlanes()
        ]).then (result) =>
            @kanbanUserstoriesService.reset(false)
            userstories = result[0]
            swimlanes = result[1]
            @.notFoundUserstories = false

            if !userstories.length && ((@.filterQ && @.filterQ.length) || Object.keys(@location.search()).length)
                @.notFoundUserstories = true

            @kanbanUserstoriesService.init(@scope.project, swimlanes, @scope.usersById)
            @tgLoader.pageLoaded()
            @.renderUserStories(userstories)

            return userstories

        return promise

    loadUserStoriesForStatus: (ctx, statusId) ->
        filteredStatus = @location.search().status

        # if there are filters applied the action doesn't end if the statusId is not in the url
        if filteredStatus
            filteredStatus = filteredStatus.split(",").map (it) -> parseInt(it, 10)

            return if filteredStatus.indexOf(statusId) == -1

        params = {
            status: statusId
            include_attachments: true,
            include_tasks: true
        }

        if @.filterQ
            params.q = @.filterQ

        params = _.merge params, @location.search()

        return @rs.userstories.listAll(@scope.projectId, params).then (userstories) =>
            @.waitEmptyQuote () =>
                @scope.$broadcast("kanban:shown-userstories-for-status", statusId, userstories)

            return userstories

    waitEmptyQuote: (cb) ->
        if @.queue.length > 0
            requestAnimationFrame () => @.waitEmptyQuote(cb)
        else
            scopeDefer @scope, => cb()

    hideUserStoriesForStatus: (ctx, statusId) ->
        @scope.$broadcast("kanban:hidden-userstories-for-status", statusId)

    loadKanban: ->
        return @q.all([
            @.refreshTagsColors(),
            @.loadUserstories()
        ])

    loadSwimlanes: ->
        return @rs.swimlanes.list(@scope.projectId).then (swimlanes) =>
            @scope.swimlanes = swimlanes
            @scope.swimlanesStatuses = {}

            @scope.swimlanes.forEach (swimlane) =>
                @scope.swimlanesStatuses[swimlane.id] = swimlane.statuses

            @scope.swimlanesStatuses[-1] = @scope.project.us_statuses

            return @scope.swimlanes

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.is_kanban_activated
            @errorHandlingService.permissionDenied()

        @scope.projectId = project.id
        @scope.project = project
        @scope.projectId = project.id
        @scope.points = _.sortBy(project.points, "order")
        @scope.pointsById = groupBy(project.points, (x) -> x.id)
        @scope.usStatusById = groupBy(project.us_statuses, (x) -> x.id)
        @scope.usStatusList = _.sortBy(project.us_statuses, "order")
        @scope.usCardVisibility = {}

        @scope.$emit("project:loaded", project)
        return project

    loadInitialData: ->
        project = @.loadProject()
        @.foldedSwimlane = Immutable.fromJS(@rs.kanban.getSwimlanesModes(project.id))
        @.initialLoad = false

        @.fillUsersAndRoles(project.members, project.roles)
        @.initializeSubscription()
        @.loadKanban().then () =>
            @timeout () =>
                @.initialLoad = true
            , 0, true

        @.generateFilters()

    moveUs: (ctx, usList, newStatusId, newSwimlaneId, index, previousCard, nextCard) ->
        @.cleanSelectedUss()

        usList = _.map usList, (us) =>
            return @kanbanUserstoriesService.getUsModel(us.id)

        @rootscope.$broadcast("kanban:userstories:loaded", usList, newStatusId, newSwimlaneId, index)

        apiNewSwimlaneId = newSwimlaneId

        if newSwimlaneId == -1
            apiNewSwimlaneId = null

        data = @kanbanUserstoriesService.move(
            usList.map((it) => it.id),
            newStatusId,
            apiNewSwimlaneId,
            index,
            previousCard,
            nextCard
        )

        promise = @rs.userstories.bulkUpdateKanbanOrder(
            @scope.projectId,
            newStatusId,
            apiNewSwimlaneId,
            data.afterUserstoryId,
            data.beforeUserstoryId,
            data.bulkUserstories
        )

        promise.then () =>
            @scope.$broadcast("redraw:wip")

            @.generateFilters()
            if @.isFilterDataTypeSelected('status')
                @.filtersReloadContent()

module.controller("KanbanController", KanbanController)

#############################################################################
## Kanban Directive
#############################################################################
KanbanDirective = ($repo, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        watchKanbanSize = () =>
            columns = $el.find(".task-colum-name")
            kanbanStyles = getComputedStyle($el[0])
            columnMargin = Number(kanbanStyles.getPropertyValue('--kanban-column-margin')
                .trim()
                .replace('px', '')
                .split(' ')[1])

            resizeCb = (entries) =>
                    width = columns.toArray().reduce (acc, column) =>
                        if document.body.contains(column)
                            return acc + column.offsetWidth + columnMargin

                        resizeObserver.unobserve(column)
                        return acc
                    , 0

                    if width > 0
                        document.body.style.setProperty('--kanban-width', (width - columnMargin) + 'px')

            resizeObserver = new ResizeObserver(resizeCb)

            columns.each (index, column) =>
                resizeObserver.observe(column)

        board = initBoard()
        board.events (event, data) =>
            # the card is visible in the scroll viewport
            if event == 'SHOW_CARD'
                if !$scope.usCardVisibility[data.id] && data.visible
                    $scope.$evalAsync () =>
                        $scope.usCardVisibility[data.id] = data.visible

            return

        $scope.taskColumnLoaded = (event, status, swimlane) ->
            column = event.target[0]
            board.addSwimlane(column, status, swimlane)

        $scope.cardLoaded = (event, status, swimlane) ->
            board.addCard(event.target[0], status, swimlane)

        _tableBody = null

        $scope.isTableLoaded = false

        $scope.kanbanTableLoaded = (event, swimlaneId) ->
            $scope.$evalAsync () =>
                # we only want to track when the user open a new swimlane for d&d
                if swimlaneId
                    $scope.openSwimlane(swimlaneId)

                $scope.isTableLoaded = true

            tableBody = event.target
            _tableBody = tableBody
            tableHeaderDom = $el.find(".kanban-table-header .kanban-table-inner")

            tableBody.on "scroll", (event) ->
                scroll = -1 * event.currentTarget.scrollLeft
                tableHeaderDom.css("transform", "translateX(#{scroll}px)")

            watchKanbanSize()

            return

        $scope.$on "$destroy", ->
            $el.off()
            if _tableBody
                _tableBody.off()

    return {link: link}

module.directive("tgKanban", ["$tgRepo", "$rootScope", KanbanDirective])

#############################################################################
## Kanban Archived Show Status
#############################################################################

KanbanArchivedShowStatusHeaderDirective = ($rootscope, $translate, kanbanUserstoriesService) ->
    showArchivedText = $translate.instant("KANBAN.ACTION_SHOW_ARCHIVED")

    link = ($scope, $el, $attrs) ->
        unwatch = $scope.$watch 'ctrl.initialLoad', (initialLoad) =>
            return if !initialLoad

            unwatch()

            status = $scope.$eval($attrs.tgKanbanArchivedShowStatusHeader)
            show = false

            kanbanUserstoriesService.addArchivedStatus(status.id)
            kanbanUserstoriesService.hideStatus(status.id)

            $el.on "click", (event) ->
                $scope.$apply ->
                    if !show
                        $rootscope.$broadcast("kanban:show-userstories-for-status", status.id)
                        kanbanUserstoriesService.showStatus(status.id)
                        show = true

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgKanbanArchivedShowStatusHeader", [ "$rootScope", "$translate", "tgKanbanUserstories", KanbanArchivedShowStatusHeaderDirective])

#############################################################################
## Kanban Archived Status Column Intro Directive
#############################################################################

KanbanArchivedStatusIntroDirective = ($translate, kanbanUserstoriesService) ->
    userStories = []

    link = ($scope, $el, $attrs) ->
        status = $scope.$eval($attrs.tgKanbanArchivedStatusIntro)

        $scope.$on "kanban:shown-userstories-for-status", (ctx, statusId, userStoriesLoaded) ->
            if statusId == status.id
                kanbanUserstoriesService.deleteStatus(statusId)
                kanbanUserstoriesService.add(userStoriesLoaded)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgKanbanArchivedStatusIntro", ["$translate", "tgKanbanUserstories", KanbanArchivedStatusIntroDirective])

#############################################################################
## Kanban Squish Column Directive
#############################################################################

KanbanSquishColumnDirective = (rs, projectService) ->
    link = ($scope, $el, $attrs) ->
        $scope.foldStatus = (status) ->
            if !$scope.folds
                $scope.folds = rs.kanban.getStatusColumnModes(projectService.project.get('id'))

            $scope.unfold = null
            $scope.folds[status.id] = !!!$scope.folds[status.id]

            if !$scope.folds[status.id]
                $scope.unfold = status.id

            rs.kanban.storeStatusColumnModes($scope.projectId, $scope.folds)
            return

        unwatch = $scope.$watch 'ctrl.initialLoad', (load) ->
            if load && $scope.usByStatus?.size
                $scope.folds = rs.kanban.getStatusColumnModes(projectService.project.get('id'))

                archivedFolds = $scope.usStatusList.filter (status) ->
                    return status.is_archived

                for status in archivedFolds
                    $scope.folds[status.id] = true

                unwatch()

    return {link: link}

module.directive("tgKanbanSquishColumn", ["$tgResources", "tgProjectService", KanbanSquishColumnDirective])

#############################################################################
## Kanban WIP Limit Directive
#############################################################################

KanbanWipLimitDirective = ($timeout) ->
    link = ($scope, $el, $attrs) ->
        status = $scope.$eval($attrs.tgKanbanWipLimit)

        redrawWipLimit = =>
            $timeout =>
                cards = $el.find("tg-card")

                wipLimitClass = ''
                element = null

                if cards.length + 1 == status.wip_limit
                    wipLimitClass = 'one-left'
                    element = cards[cards.length - 1]
                else if cards.length == status.wip_limit
                    wipLimitClass = 'reached'
                    element = cards[cards.length - 1]
                else if cards.length > status.wip_limit
                    wipLimitClass = 'exceeded'
                    element = cards[status.wip_limit - 1]

                $el.find(".kanban-wip-limit").remove()

                if element
                    angular.element(element).after("<div class='kanban-wip-limit #{wipLimitClass}'><span>WIP Limit</span></div>")
            , 0, false

        if status and not status.is_archived
            $scope.$on "redraw:wip", redrawWipLimit
            $scope.$on "kanban:us:move", redrawWipLimit
            $scope.$on "usform:new:success", redrawWipLimit
            $scope.$on "usform:bulk:success", redrawWipLimit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgKanbanWipLimit", ["$timeout", KanbanWipLimitDirective])

CardSvgTemplate = """
    <tg-svg>
        <svg class="icon <%- svgIcon %>" style="fill: <%- svgFill %>">
            <use xlink:href="#<%- svgIcon %>" attr-href="#<%- svgIcon %>">
                <% if(svgTitle) { %>
                <title><%- svgTitle %></title>
                <% } %>
            </use>
        </svg>
    </tg-svg>
    """

CardAssignedToDirective = ($template, $translate, avatarService, projectService) ->
    template = $template.get("components/card/card-templates/card-assigned-to.html", true)
    svgTemplate  = _.template(CardSvgTemplate)

    render = (vm) =>
        avatars = {}
        (vm.item.get('assigned_users') || [vm.item.get('assigned_to')]).forEach (user) =>
            if user
                avatars[user.get('id')] = avatarService.getAvatar(user, 'avatar')

        return template({
            vm: vm,
            avatars: avatars,
            translate: (key, params) =>
                return $translate.instant(key, params)
            checkPermission: (permission) =>
                return projectService.project.get('my_permissions').indexOf(permission) > -1
            svg: (svgData) =>
                return svgTemplate(Object.assign({
                    svgTitle: '',
                    svgFill: ''
                }, svgData))
            loading: """
                <img
                    class='loading-spinner'
                    src='/#{window._version}/svg/spinner-circle.svg'
                    alt='loading...'
                />
            """
        })

    return {
        scope: {
            zoomLevel: '<',
            item: '<',
            vm: '<'
        },
        link: ($scope, $el) ->
            initializeZoom = false

            onChange = () =>
                html = render($scope.vm)
                $el.off()

                $el.html(html)

                $el.find('.card-assigned-to-action').on 'click', (event) =>
                    if !event.ctrlKey && !event.metaKey
                        $scope.vm.onClickAssignedTo({id: $scope.vm.item.get('id')})

                $el.find('.js-card-edit-content').on 'click', (event) =>
                    event.preventDefault()
                    if !event.ctrlKey && !event.metaKey
                        $scope.vm.onClickEdit({id: $scope.vm.item.get('id')})

                $el.find('.js-card-remove').on 'click', (event) =>
                    event.preventDefault()
                    if !event.ctrlKey && !event.metaKey
                        $scope.vm.onClickRemove({id: $scope.vm.item.get('id')})

                $el.find('.js-card-delete').on 'click', (event) =>
                    event.preventDefault()
                    if !event.ctrlKey && !event.metaKey
                        $scope.vm.onClickDelete({id: $scope.vm.item.get('id')})

            $scope.$watch 'item', onChange
            # ignore the first watch because is the same as item
            $scope.$watch 'zoomLevel', () =>
                if initializeZoom
                    onChange()
                else
                    initializeZoom = true

            $scope.$on "$destroy", ->
                $el.off()
    }


module.directive("tgCardAssignedTo", [
    "$tgTemplate",
    "$translate",
    "tgAvatarService",
    "tgProjectService",
    CardAssignedToDirective])

CardDataDirective = ($template, $translate, avatarService, projectService, dueDateService) ->
    template = $template.get("components/card/card-templates/card-data.html", true)
    svgTemplate  = _.template(CardSvgTemplate)

    render = (vm) =>
        avatars = {}
        (vm.item.get('assigned_users') || []).forEach (user) =>
            avatars[user.get('id')] = avatarService.getAvatar(user, 'avatar')

        return template({
            vm: vm,
            avatars: avatars,
            emptyTask: () =>
                tasks = vm.item.getIn(['model', 'tasks'])
                return !tasks || !tasks.size
            dueDateColor: () =>
                dueDateService.color({
                    dueDate: vm.item.getIn(['model', 'due_date']),
                    isClosed: vm.item.getIn(['model', 'is_closed']),
                    objType: vm.type
                })
            dueDateTitle: () =>
                dueDateService.title({
                    dueDate: vm.item.getIn(['model', 'due_date']),
                    isClosed: vm.item.getIn(['model', 'is_closed']),
                    objType: vm.type
                })
            totalAttachments: () =>
                if vm.type == 'task'
                    return vm.item.getIn(['model', 'attachments']).size
                else
                    return vm.item.getIn(['model', 'total_attachments'])

            translate: (key, params) =>
                return $translate.instant(key, params)
            svg: (svgData) =>
                return svgTemplate(Object.assign({
                    svgTitle: '',
                    svgFill: ''
                }, svgData))
        })

    return {
        scope: {
            zoomLevel: '<',
            item: '<',
            vm: '<'
        },
        link: ($scope, $el) ->
            initializeZoom = false

            onChange = () =>
                html = render($scope.vm)
                $el.off()

                $el.html(html)

            $scope.$watch 'item', onChange
            # ignore the first watch because is the same as item
            $scope.$watch 'zoomLevel', () =>
                if initializeZoom
                    onChange()
                else
                    initializeZoom = true

            $scope.$on "$destroy", ->
                $el.off()
    }

module.directive("tgCardData", [
    "$tgTemplate",
    "$translate",
    "tgAvatarService",
    "tgProjectService",
    "tgDueDateService",
    CardDataDirective])

#############################################################################
## Kanban Swimlane Directive
#############################################################################
KanbanSwimlaneDirective = ($timeout) ->
    link = ($scope, $el, $attrs) ->
        tableHeaderDom = []
        addSwimlane = null
        ctrl = $scope.$parent.ctrl

        if !ctrl
            throw new Error('KanbanSwimlaneDirective ctrl not found')

        # sticky swimlane title
        $el.on "scroll", (event) ->
            if !tableHeaderDom.length
                tableHeaderDom = $el.find(".kanban-swimlane-title")
            if !addSwimlane
                addSwimlane = $el.find(".kanban-swimlane-add")

            scroll = event.currentTarget.scrollLeft
            tableHeaderDom.css("transform", "translateX(#{scroll}px)")
            addSwimlane.css("transform", "translateX(#{scroll}px)")

        currentSwimlane = null
        className = 'pending-to-open'

        $scope.mouseleaveSwimlane = (event) =>
            if currentSwimlane
                $timeout.cancel(currentSwimlane.timeoutId)
                currentSwimlane.el.classList.remove(className)
                currentSwimlane = null

        $scope.mouseoverSwimlane = (event, swimlaneId) =>
            return if currentSwimlane && currentSwimlane.id == swimlaneId

            if currentSwimlane
                $timeout.cancel(currentSwimlane.timeoutId)
                currentSwimlane.el.classList.remove(className)

            swimlane = event.currentTarget

            if swimlane.classList.contains('folded')
                isDragging = !!document.querySelectorAll('tg-card.gu-mirror').length

                return if !isDragging

                swimlane.classList.add(className)

                timeoutId = $timeout () ->
                    swimlane.classList.remove(className)
                    ctrl.toggleSwimlane(swimlaneId)
                , 1000

                currentSwimlane = {
                    id: swimlaneId,
                    timeoutId: timeoutId,
                    el: swimlane
                }

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgKanbanSwimlane", ['$timeout', KanbanSwimlaneDirective])

#############################################################################
## Kanban Swimlane Taskboard Column Directive
#############################################################################
KanbanTaskboardColumnDirective = () ->
    link = ($scope, $el, $attrs) ->
        # sticky num us counter
        $el.on "scroll", (event) ->
            scroll = event.currentTarget.scrollTop
            taskCounterDom = $el.find(".kanban-task-counter")
            taskCounterDom.css("transform", "translateY(#{scroll}px)")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgKanbanTaskboardColumn", [KanbanTaskboardColumnDirective])
