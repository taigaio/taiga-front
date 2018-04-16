###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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

#############################################################################
## Kanban Controller
#############################################################################

class KanbanController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin, taiga.UsFiltersMixin)
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
        "tgProjectService"
    ]

    storeCustomFiltersName: 'kanban-custom-filters'
    storeFiltersName: 'kanban-filters'

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @rs2, @params, @q, @location,
                  @appMetaService, @navUrls, @events, @analytics, @translate, @errorHandlingService,
                  @model, @kanbanUserstoriesService, @storage, @filterRemoteStorageService, @projectService) ->
        bindMethods(@)
        @kanbanUserstoriesService.reset()
        @.openFilter = false
        @.selectedUss = {}

        return if @.applyStoredFilters(@params.pslug, "kanban-filters")

        @scope.sectionName = @translate.instant("KANBAN.SECTION_NAME")
        @.initializeEventHandlers()

        taiga.defineImmutableProperty @.scope, "usByStatus", () =>
            return @kanbanUserstoriesService.usByStatus

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
        if @.zoomLevel == zoomLevel
            return null

        @.isFirstLoad = !@.zoomLevel

        previousZoomLevel = @.zoomLevel

        @.zoomLevel = zoomLevel
        @.zoom = zoom

        if @.isFirstLoad
            @.firstLoad().then () =>
                @.isFirstLoad = false
                @kanbanUserstoriesService.resetFolds()

        else if @.zoomLevel > 1 && previousZoomLevel <= 1
            @.zoomLoading = true

            @.loadUserstories().then () =>
                @.zoomLoading = false
                @kanbanUserstoriesService.resetFolds()

    filtersReloadContent: () ->
        @.loadUserstories().then () =>
            openArchived = _.difference(@kanbanUserstoriesService.archivedStatus,
                                        @kanbanUserstoriesService.statusHide)
            if openArchived.length
                for statusId in openArchived
                    @.loadUserStoriesForStatus({}, statusId)

    initializeEventHandlers: ->
        @scope.$on "usform:new:success", (event, us) =>
            @.refreshTagsColors().then () =>
                @kanbanUserstoriesService.add(us)

            @analytics.trackEvent("userstory", "create", "create userstory on kanban", 1)

        @scope.$on "usform:bulk:success", (event, uss) =>
            @.refreshTagsColors().then () =>
                @kanbanUserstoriesService.add(uss)

            @analytics.trackEvent("userstory", "create", "bulk create userstory on kanban", 1)

        @scope.$on "usform:edit:success", (event, us) =>
            @.refreshTagsColors().then () =>
                @kanbanUserstoriesService.replaceModel(us)

        @scope.$on("assigned-to:added", @.onAssignedToChanged)
        @scope.$on("assigned-user:added", @.onAssignedUsersChanged)
        @scope.$on("assigned-user:deleted", @.onAssignedUsersDeleted)
        @scope.$on("kanban:us:move", @.moveUs)
        @scope.$on("kanban:show-userstories-for-status", @.loadUserStoriesForStatus)
        @scope.$on("kanban:hide-userstories-for-status", @.hideUserStoriesForStatus)

    addNewUs: (type, statusId) ->
        switch type
            when "standard" then @rootscope.$broadcast("usform:new",
                                                       @scope.projectId, statusId, @scope.usStatusList)
            when "bulk" then @rootscope.$broadcast("usform:bulk",
                                                   @scope.projectId, statusId)

    editUs: (id) ->
        us = @kanbanUserstoriesService.getUs(id)
        us = us.set('loading', true)
        @kanbanUserstoriesService.replace(us)

        @rs.userstories.getByRef(us.getIn(['model', 'project']), us.getIn(['model', 'ref']))
         .then (editingUserStory) =>
            @rs2.attachments.list("us", us.get('id'), us.getIn(['model', 'project'])).then (attachments) =>
                @rootscope.$broadcast("usform:edit", editingUserStory, attachments.toJS())

                us = us.set('loading', false)
                @kanbanUserstoriesService.replace(us)

    showPlaceHolder: (statusId) ->
        if @scope.usStatusList[0].id == statusId &&
          !@kanbanUserstoriesService.userstoriesRaw.length
            return true

        return false

    toggleFold: (id) ->
        @kanbanUserstoriesService.toggleFold(id)

    isUsInArchivedHiddenStatus: (usId) ->
        return @kanbanUserstoriesService.isUsInArchivedHiddenStatus(usId)

    changeUsAssignedTo: (id) ->
        us = @kanbanUserstoriesService.getUsModel(id)

        @rootscope.$broadcast("assigned-to:add", us)

    changeUsAssignedUsers: (id) ->
        us = @kanbanUserstoriesService.getUsModel(id)
        @rootscope.$broadcast("assigned-user:add", us)

    onAssignedToChanged: (ctx, userid, usModel) ->
        usModel.assigned_to = userid

        @kanbanUserstoriesService.replaceModel(usModel)

        @repo.save(usModel).then =>
            @.generateFilters()
            if @.isFilterDataTypeSelected('assigned_to') || @.isFilterDataTypeSelected('role')
                @.filtersReloadContent()

    onAssignedUsersChanged: (ctx, userid, usModel) ->
        assignedUsers = _.clone(usModel.assigned_users, false)
        assignedUsers.push(userid)
        assignedUsers = _.uniq(assignedUsers)
        usModel.assigned_users = assignedUsers
        if not usModel.assigned_to
            usModel.assigned_to = userid
        @kanbanUserstoriesService.replaceModel(usModel)

        promise = @repo.save(usModel)
        promise.then null, ->
            console.log "FAIL" # TODO

    onAssignedUsersDeleted: (ctx, userid, usModel) ->
        assignedUsersIds = _.clone(usModel.assigned_users, false)
        assignedUsersIds = _.pull(assignedUsersIds, userid)
        assignedUsersIds = _.uniq(assignedUsersIds)
        usModel.assigned_users = assignedUsersIds

        # Update as
        if usModel.assigned_to not in assignedUsersIds and assignedUsersIds.length > 0
            usModel.assigned_to = assignedUsersIds[0]
        if assignedUsersIds.length == 0
            usModel.assigned_to = null

        @kanbanUserstoriesService.replaceModel(usModel)

        promise = @repo.save(usModel)
        promise.then null, ->
            console.log "FAIL" # TODO

    refreshTagsColors: ->
        return @rs.projects.tagsColors(@scope.projectId).then (tags_colors) =>
            @scope.project.tags_colors = tags_colors._attrs

    loadUserstories: () ->
        params = {
            status__is_archived: false
        }

        if @.zoomLevel > 1
            params.include_attachments = 1
            params.include_tasks = 1

        params = _.merge params, @location.search()

        promise = @rs.userstories.listAll(@scope.projectId, params).then (userstories) =>
            @kanbanUserstoriesService.init(@scope.project, @scope.usersById)
            @kanbanUserstoriesService.set(userstories)

            # The broadcast must be executed when the DOM has been fully reloaded.
            # We can't assure when this exactly happens so we need a defer
            scopeDefer @scope, =>
                @scope.$broadcast("userstories:loaded", userstories)

            return userstories

        promise.then( => @scope.$broadcast("redraw:wip"))

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

        params = _.merge params, @location.search()

        return @rs.userstories.listAll(@scope.projectId, params).then (userstories) =>
            @scope.$broadcast("kanban:shown-userstories-for-status", statusId, userstories)

            return userstories

    hideUserStoriesForStatus: (ctx, statusId) ->
        @scope.$broadcast("kanban:hidden-userstories-for-status", statusId)

    loadKanban: ->
        return @q.all([
            @.refreshTagsColors(),
            @.loadUserstories()
        ])

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

        @scope.$emit("project:loaded", project)
        return project

    initializeSubscription: ->
        routingKey1 = "changes.project.#{@scope.projectId}.userstories"
        @events.subscribe @scope, routingKey1, (message) =>
            @.loadUserstories()

    loadInitialData: ->
        project = @.loadProject()

        @.fillUsersAndRoles(project.members, project.roles)
        @.initializeSubscription()
        @.loadKanban()
        @.generateFilters()

    # Utils methods

    prepareBulkUpdateData: (uses, field="kanban_order") ->
        return _.map(uses, (x) -> {"us_id": x.id, "order": x[field]})

    moveUs: (ctx, usList, newStatusId, index) ->
        @.cleanSelectedUss()

        usList = _.map usList, (us) =>
            return @kanbanUserstoriesService.getUsModel(us.id)

        data = @kanbanUserstoriesService.move(usList, newStatusId, index)

        promise = @rs.userstories.bulkUpdateKanbanOrder(@scope.projectId, newStatusId, data.bulkOrders)

        promise.then () =>
            # saving
            # drag single or different status
            options = {
                headers: {
                    "set-orders": JSON.stringify(data.setOrders)
                }
            }

            params = {
                include_attachments: true,
                include_tasks: true
            }

            promises = _.map usList, (us) =>
                @repo.save(us, true, params, options, true)

            promise = @q.all(promises)

            promise.then (result) =>
                headers = result[1]

                if headers && headers['taiga-info-order-updated']
                    order = JSON.parse(headers['taiga-info-order-updated'])
                    @kanbanUserstoriesService.assignOrders(order)
                @scope.$broadcast("redraw:wip")

                @.generateFilters()
                if @.isFilterDataTypeSelected('status')
                    @.filtersReloadContent()

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
## Kanban Archived Status Column Header Control
#############################################################################

KanbanArchivedStatusHeaderDirective = ($rootscope, $translate, kanbanUserstoriesService) ->
    showArchivedText = $translate.instant("KANBAN.ACTION_SHOW_ARCHIVED")
    hideArchivedText = $translate.instant("KANBAN.ACTION_HIDE_ARCHIVED")

    link = ($scope, $el, $attrs) ->
        status = $scope.$eval($attrs.tgKanbanArchivedStatusHeader)
        hidden = true

        kanbanUserstoriesService.addArchivedStatus(status.id)
        kanbanUserstoriesService.hideStatus(status.id)

        $scope.class = "icon-watch"
        $scope.title = showArchivedText

        $el.on "click", (event) ->
            hidden = not hidden

            $scope.$apply ->
                if hidden
                    $scope.class = "icon-watch"
                    $scope.title = showArchivedText
                    $rootscope.$broadcast("kanban:hide-userstories-for-status", status.id)

                    kanbanUserstoriesService.hideStatus(status.id)
                else
                    $scope.class = "icon-unwatch"
                    $scope.title = hideArchivedText
                    $rootscope.$broadcast("kanban:show-userstories-for-status", status.id)

                    kanbanUserstoriesService.showStatus(status.id)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgKanbanArchivedStatusHeader", [ "$rootScope", "$translate", "tgKanbanUserstories", KanbanArchivedStatusHeaderDirective])


#############################################################################
## Kanban Archived Status Column Intro Directive
#############################################################################

KanbanArchivedStatusIntroDirective = ($translate, kanbanUserstoriesService) ->
    userStories = []

    link = ($scope, $el, $attrs) ->
        hiddenUserStoriexText = $translate.instant("KANBAN.HIDDEN_USER_STORIES")
        status = $scope.$eval($attrs.tgKanbanArchivedStatusIntro)
        $el.text(hiddenUserStoriexText)

        updateIntroText = (hasArchived) ->
            if hasArchived
                $el.text("")
            else
                $el.text(hiddenUserStoriexText)

        $scope.$on "kanban:us:move", (ctx, itemUs, oldStatusId, newStatusId, itemIndex) ->
            hasArchived = !!kanbanUserstoriesService.getStatus(newStatusId).length
            updateIntroText(hasArchived)

        $scope.$on "kanban:shown-userstories-for-status", (ctx, statusId, userStoriesLoaded) ->
            if statusId == status.id
                kanbanUserstoriesService.deleteStatus(statusId)
                kanbanUserstoriesService.add(userStoriesLoaded)

                hasArchived = !!kanbanUserstoriesService.getStatus(statusId).length
                updateIntroText(hasArchived)

        $scope.$on "kanban:hidden-userstories-for-status", (ctx, statusId) ->
            if statusId == status.id
                updateIntroText(false)

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

        unwatch = $scope.$watch 'usByStatus', (usByStatus) ->
            if usByStatus.size
                $scope.folds = rs.kanban.getStatusColumnModes(projectService.project.get('id'))
                updateTableWidth()

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
            $el.find(".kanban-wip-limit").remove()
            $timeout =>
                element = $el.find("tg-card")[status.wip_limit]
                if element
                    angular.element(element).before("<div class='kanban-wip-limit'></div>")

        if status and not status.is_archived
            $scope.$on "redraw:wip", redrawWipLimit
            $scope.$on "kanban:us:move", redrawWipLimit
            $scope.$on "usform:new:success", redrawWipLimit
            $scope.$on "usform:bulk:success", redrawWipLimit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgKanbanWipLimit", ["$timeout", KanbanWipLimitDirective])
