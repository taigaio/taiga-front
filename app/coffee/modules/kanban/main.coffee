###
# Copyright (C) 2014-2015 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014-2015 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2015 David Barragán Merino <bameda@dbarragan.com>
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
viewModes = [
    "maximized",
    "minimized"
]


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
        "tgAppMetaService",
        "$tgNavUrls",
        "$tgEvents",
        "$tgAnalytics",
        "$translate"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location,
                  @appMetaService, @navUrls, @events, @analytics, @translate) ->

        bindMethods(@)

        @activeFilters = false

        @scope.sectionName = @translate.instant("KANBAN.SECTION_NAME")
        @scope.statusViewModes = {}
        @.initializeEventHandlers()

        promise = @.loadInitialData()
        
        # On Success
        promise.then =>
            title = @translate.instant("KANBAN.PAGE_TITLE", {projectName: @scope.project.name})
            description = @translate.instant("KANBAN.PAGE_DESCRIPTION", {
                projectName: @scope.project.name,
                projectDescription: @scope.project.description
            })
            @appMetaService.setAll(title, description)
            @.generateFilters()

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
        @scope.$on("kanban:show-userstories-for-status", @.loadUserStoriesForStatus)
        @scope.$on("kanban:hide-userstories-for-status", @.hideUserStoriesForStatus)

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
    refreshTagsColors: ->
        return @rs.projects.tagsColors(@scope.projectId).then (tags_colors) =>
            @scope.project.tags_colors = tags_colors

    loadUserstories: ->
        params = {
            status__is_archived: false
        }

        return @rs.userstories.listAll(@scope.projectId, params).then (userstories) =>
            @scope.userstories = userstories

            usByStatus = _.groupBy(userstories, "status")
            us_archived = []
            for status in @scope.usStatusList
                if not usByStatus[status.id]?
                    usByStatus[status.id] = []
                if @scope.usByStatus?
                    for us in @scope.usByStatus[status.id]
                        if us.status != status.id
                            us_archived.push(us)

                # Must preserve the archived columns if loaded
                if status.is_archived and @scope.usByStatus? and @scope.usByStatus[status.id].length != 0
                    for us in @scope.usByStatus[status.id].concat(us_archived)
                        if us.status == status.id
                            usByStatus[status.id].push(us)

                usByStatus[status.id] = _.sortBy(usByStatus[status.id], "kanban_order")

            if userstories.length == 0
                status = @scope.usStatusList[0]
                usByStatus[status.id].push({isPlaceholder: true})

            @scope.usByStatus = usByStatus

            # The broadcast must be executed when the DOM has been fully reloaded.
            # We can't assure when this exactly happens so we need a defer
            scopeDefer @scope, =>
                @scope.$broadcast("userstories:loaded", userstories)

            return userstories

    loadUserStoriesForStatus: (ctx, statusId) ->
        params = { status: statusId }
        return @rs.userstories.listAll(@scope.projectId, params).then (userstories) =>
            @scope.usByStatus[statusId] = _.sortBy(userstories, "kanban_order")
            @scope.$broadcast("kanban:shown-userstories-for-status", statusId, userstories)
            return userstories

    hideUserStoriesForStatus: (ctx, statusId) ->
        @scope.usByStatus[statusId] = []
        @scope.$broadcast("kanban:hidden-userstories-for-status", statusId)

    loadKanban: ->
        return @q.all([
            @.refreshTagsColors(),
            @.loadUserstories()
        ])

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            if not project.is_kanban_activated
                @location.path(@navUrls.resolve("permission-denied"))

            @scope.projectId = project.id
            @scope.project = project
            @scope.projectId = project.id
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
        promise = @.loadProject()
        return promise.then (project) =>
            @.fillUsersAndRoles(project.members, project.roles)
            @.initializeSubscription()
            @.loadKanban().then( => @scope.$broadcast("redraw:wip"))


    ## View Mode methods

    generateStatusViewModes: ->
        storedStatusViewModes = @rs.kanban.getStatusViewModes(@scope.projectId)

        @scope.statusViewModes = {}
        for status in @scope.usStatusList
            mode = storedStatusViewModes[status.id] || defaultViewMode

            @scope.statusViewModes[status.id] = mode

        @.storeStatusViewModes()

    storeStatusViewModes: ->
        @rs.kanban.storeStatusViewModes(@scope.projectId, @scope.statusViewModes)

    updateStatusViewMode: (statusId, newViewMode) ->
        @scope.statusViewModes[statusId] = newViewMode
        @.storeStatusViewModes()

    isMaximized: (statusId) ->
        mode = @scope.statusViewModes[statusId] or defaultViewMode
        return mode == 'maximized'

    isMinimized: (statusId) ->
        mode = @scope.statusViewModes[statusId] or defaultViewMode
        return mode == 'minimized'

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

    moveUs: (ctx, us, oldStatusId, newStatusId, index) ->
        if oldStatusId != newStatusId
            # Remove us from old status column
            r = @scope.usByStatus[oldStatusId].indexOf(us)
            @scope.usByStatus[oldStatusId].splice(r, 1)

            # Add us to new status column.
            @scope.usByStatus[newStatusId].splice(index, 0, us)
            us.status = newStatusId
        else
            r = @scope.usByStatus[newStatusId].indexOf(us)
            @scope.usByStatus[newStatusId].splice(r, 1)
            @scope.usByStatus[newStatusId].splice(index, 0, us)

        itemsToSave = @.resortUserStories(@scope.usByStatus[newStatusId])
        @scope.usByStatus[newStatusId] = _.sortBy(@scope.usByStatus[newStatusId], "kanban_order")

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
    
    getUrlFilters: ->
        return _.pick(@location.search(), "status", "tags", "owners", "q")
        
    generateFilters: ->
        urlfilters = @.getUrlFilters()
        @scope.filters =  {}

        loadFilters = {}
        loadFilters.project = @scope.projectId
        loadFilters.tags = urlfilters.tags
        loadFilters.status = urlfilters.status
        loadFilters.owners = urlfilters.owners
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
            
            loadOwners = (owners) =>
                return _.map owners, (t) ->
                    t.id = t.full_name
                    t.name = t.full_name
                    t.type = 'owners'
                    return t

            # Build filters data structure
            @scope.filters.status = choicesFiltersFormat(data.statuses, "status", @scope.usStatusById)
            @scope.filters.tags = tagsFilterFormat(data.tags)
            @scope.filters.owners = loadOwners(data.owners)

            selectedTags = _.filter(@scope.filters.tags, "selected")
            selectedTags = _.map(selectedTags, "id")

            selectedStatuses = _.filter(@scope.filters.status, "selected")
            selectedStatuses = _.map(selectedStatuses, "id")
            
            selectedOwners = _.filter(@scope.filters.owners, "selected")
            selectedOwners = _.map(selectedOwners, "id")

            @.markSelectedFilters(@scope.filters, urlfilters)

            #store query params
            @rs.userstories.storeQueryParams(@scope.projectId, {
                "status": selectedStatuses,
                "tags": selectedTags,
                "owners": selectedOwners,
                "project": @scope.projectId
                "milestone": null
            })
                
    toggleActiveFilters: ->
        @activeFilters = !@activeFilters
        
    resetFilters: ->
        selectedTags = _.filter(@scope.filters.tags, "selected")
        selectedStatuses = _.filter(@scope.filters.status, "selected")

        @scope.filtersQ = ""

        _.each [selectedTags, selectedStatuses], (filterGrp) =>
            _.each filterGrp, (item) =>
                filters = @scope.filters[item.type]
                filter = _.find(filters, {id: taiga.toString(item.id)})
                filter.selected = false

                @.unselectFilter(item.type, item.id)

        @.loadUserstories()
        @rootscope.$broadcast("filters:update")
        
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
    
module.controller("KanbanController", KanbanController)

#############################################################################
## Kanban Directive
#############################################################################

KanbanDirective = ($repo, $rootscope, $translate) ->
     
    showHideFilter = ($scope, $el, $ctrl) ->
        sidebar = $el.find("sidebar.filters-bar")
        sidebar.one "transitionend", () ->
            timeout 150, ->
                $rootscope.$broadcast("resize")
                $('.burndown').css("visibility", "visible")

        target = angular.element("#show-filters-button")
        sidebar.toggleClass("active")
        target.toggleClass("active")

        hideText = $translate.instant("BACKLOG.FILTERS.HIDE")
        showText = $translate.instant("BACKLOG.FILTERS.SHOW")

        toggleText(target.find(".text"), [hideText, showText])

        if !sidebar.hasClass("active")
            $ctrl.resetFilters()

        $ctrl.toggleActiveFilters()
        
    linkFilters = ($scope, $el, $attrs, $ctrl) ->
        $scope.filtersSearch = {}
        $el.on "click", "#show-filters-button", (event) ->
            event.preventDefault()
            $scope.$apply ->
                showHideFilter($scope, $el, $ctrl)  
                 
    link = ($scope, $el, $attrs, $ctrl) ->
        tableBodyDom = $el.find(".kanban-table-body")

        tableBodyDom.on "scroll", (event) ->
            target = angular.element(event.currentTarget)
            tableHeaderDom = $el.find(".kanban-table-header .kanban-table-inner")
            tableHeaderDom.css("left", -1 * target.scrollLeft())

        $ctrl = $el.controller()
        linkFilters($scope, $el, $attrs, $ctrl)
        
        $scope.$on "$destroy", ->
            $el.off()
        
    return {link: link}

module.directive("tgKanban", ["$tgRepo", "$rootScope", "$translate", KanbanDirective])

#############################################################################
## Kanban Archived Status Column Header Control
#############################################################################

KanbanArchivedStatusHeaderDirective = ($rootscope, $translate) ->
    showArchivedText = $translate.instant("KANBAN.ACTION_SHOW_ARCHIVED")
    hideArchivedText = $translate.instant("KANBAN.ACTION_HIDE_ARCHIVED")

    link = ($scope, $el, $attrs) ->
        status = $scope.$eval($attrs.tgKanbanArchivedStatusHeader)
        hidden = true

        $scope.class = "icon-open-eye"
        $scope.title = showArchivedText

        $el.on "click", (event) ->
            hidden = not hidden

            $scope.$apply ->
                if hidden
                    $scope.class = "icon-open-eye"
                    $scope.title = showArchivedText
                    $rootscope.$broadcast("kanban:hide-userstories-for-status", status.id)

                else
                    $scope.class = "icon-closed-eye"
                    $scope.title = hideArchivedText
                    $rootscope.$broadcast("kanban:show-userstories-for-status", status.id)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgKanbanArchivedStatusHeader", [ "$rootScope", "$translate", KanbanArchivedStatusHeaderDirective])


#############################################################################
## Kanban Archived Status Column Intro Directive
#############################################################################

KanbanArchivedStatusIntroDirective = ($translate) ->
    userStories = []

    link = ($scope, $el, $attrs) ->
        hiddenUserStoriexText = $translate.instant("KANBAN.HIDDEN_USER_STORIES")
        status = $scope.$eval($attrs.tgKanbanArchivedStatusIntro)
        $el.text(hiddenUserStoriexText)

        updateIntroText = ->
            if userStories.length > 0
                $el.text("")
            else
                $el.text(hiddenUserStoriexText)

        $scope.$on "kanban:us:move", (ctx, itemUs, oldStatusId, newStatusId, itemIndex) ->
            # The destination columnd is this one
            if status.id == newStatusId
                # Reorder
                if status.id == oldStatusId
                    r = userStories.indexOf(itemUs)
                    userStories.splice(r, 1)
                    userStories.splice(itemIndex, 0, itemUs)

                # Archiving user story
                else
                    itemUs.isArchived = true
                    userStories.splice(itemIndex, 0, itemUs)

            # Unarchiving user story
            else if status.id == oldStatusId
                itemUs.isArchived = false
                r = userStories.indexOf(itemUs)
                userStories.splice(r, 1)

            updateIntroText()

        $scope.$on "kanban:shown-userstories-for-status", (ctx, statusId, userStoriesLoaded) ->
            if statusId == status.id
                userStories = _.filter(userStoriesLoaded, (us) -> us.status == status.id)
                updateIntroText()

        $scope.$on "kanban:hidden-userstories-for-status", (ctx, statusId) ->
            if statusId == status.id
                userStories = []
                updateIntroText()

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgKanbanArchivedStatusIntro", ["$translate", KanbanArchivedStatusIntroDirective])


#############################################################################
## Kanban User Story Directive
#############################################################################

KanbanUserstoryDirective = ($rootscope, $loading, $rs) ->
    link = ($scope, $el, $attrs, $model) ->
        $el.disableSelection()

        $scope.$watch "us", (us) ->
            if us.is_blocked and not $el.hasClass("blocked")
                $el.addClass("blocked")
            else if not us.is_blocked and $el.hasClass("blocked")
                $el.removeClass("blocked")

        $el.on 'click', '.icon-edit', (event) ->
            if $el.find(".icon-edit").hasClass("noclick")
                return

            target = $(event.target)

            currentLoading = $loading()
                .target(target)
                .timeout(200)
                .removeClasses("icon-edit")
                .start()

            us = $model.$modelValue
            $rs.userstories.getByRef(us.project, us.ref).then (editingUserStory) =>
                $rootscope.$broadcast("usform:edit", editingUserStory)
                currentLoading.finish()

        $scope.getTemplateUrl = () ->
            if $scope.us.isPlaceholder
                return "common/components/kanban-placeholder.html"
            else
                return "kanban/kanban-task.html"

        $scope.$on "$destroy", ->
            $el.off()

    return {
        template: '<ng-include src="getTemplateUrl()"/>',
        link: link
        require: "ngModel"
    }

module.directive("tgKanbanUserstory", ["$rootScope", "$tgLoading", "$tgResources", KanbanUserstoryDirective])

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

        status = $scope.$eval($attrs.tgKanbanWipLimit)

        redrawWipLimit = =>
            $el.find(".kanban-wip-limit").remove()
            timeout 200, =>
                element = $el.find(".kanban-task")[status.wip_limit]
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

module.directive("tgKanbanWipLimit", KanbanWipLimitDirective)


#############################################################################
## Kanban User Directive
#############################################################################

KanbanUserDirective = ($log, $compile) ->
    template = _.template("""
    <figure class="avatar">
        <a href="#" title="{{'US.ASSIGN' | translate}}" <% if (!clickable) {%>class="not-clickable"<% } %>>
            <img src="<%- imgurl %>" alt="<%- name %>" class="avatar">
        </a>
    </figure>
    """)

    clickable = false

    link = ($scope, $el, $attrs, $model) ->
        username_label = $el.parent().find("a.task-assigned")
        username_label.addClass("not-clickable")

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

            html = $compile(template(ctx))($scope)
            $el.html(html)
            username_label.text(ctx.name)

        bindOnce $scope, "project", (project) ->
            if project.my_permissions.indexOf("modify_us") > -1
                clickable = true
                $el.on "click", (event) =>
                    if $el.find("a").hasClass("noclick")
                        return

                    us = $model.$modelValue
                    $ctrl = $el.controller()
                    $ctrl.changeUsAssignedTo(us)

                username_label.removeClass("not-clickable")
                username_label.on "click", (event) ->
                    if $el.find("a").hasClass("noclick")
                        return

                    us = $model.$modelValue
                    $ctrl = $el.controller()
                    $ctrl.changeUsAssignedTo(us)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link, require:"ngModel"}

module.directive("tgKanbanUserAvatar", ["$log", "$compile", KanbanUserDirective])
