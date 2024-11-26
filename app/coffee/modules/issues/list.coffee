###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

mixOf = @.taiga.mixOf
trim = @.taiga.trim
toString = @.taiga.toString
joinStr = @.taiga.joinStr
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
debounceLeading = @.taiga.debounceLeading
startswith = @.taiga.startswith
bindMethods = @.taiga.bindMethods
debounceLeading = @.taiga.debounceLeading

module = angular.module("taigaIssues")

#############################################################################
## Issues Controller
#############################################################################

class IssuesController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$tgUrls",
        "$routeParams",
        "$q",
        "$tgLocation",
        "tgAppMetaService",
        "$tgNavUrls",
        "$tgEvents",
        "$tgAnalytics",
        "$translate",
        "tgErrorHandlingService",
        "$tgStorage",
        "tgFilterRemoteStorageService",
        "tgProjectService",
        "tgUserActivityService"
    ]

    filtersHashSuffix: "issues-filters"
    myFiltersHashSuffix: "issues-my-filters"
    excludePrefix: "exclude_"
    filterCategories: [
        "tags",
        "status",
        "type",
        "severity",
        "priority",
        "assigned_to",
        "owner",
        "role",
    ]

    validQueryParams: [
        'exclude_tags',
        'tags',
        'exclude_status',
        'status',
        'exclude_type',
        'type',
        'exclude_severity',
        'severity',
        'exclude_priority',
        'priority',
        'exclude_assigned_to',
        'assigned_to',
        'exclude_role',
        'role',
        'exclude_owner',
        'owner',
        'order_by'
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @urls, @params, @q, @location, @appMetaService,
                  @navUrls, @events, @analytics, @translate, @errorHandlingService, @storage, @filterRemoteStorageService, @projectService) ->
        bindMethods(@)

        @showTags = true
        @scope.sectionName = @translate.instant("PROJECT.SECTION.ISSUES")
        @.voting = false
        @.openFilter = false

        return if @.applyStoredFilters(@params.pslug, @.filtersHashSuffix, @.validQueryParams)

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            title = @translate.instant("ISSUES.PAGE_TITLE", {projectName: @scope.project.name})
            description = @translate.instant("ISSUES.PAGE_DESCRIPTION", {
                projectName: @scope.project.name,
                projectDescription: @scope.project.description
            })
            @appMetaService.setAll(title, description)

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "issueform:new:success", =>
            @analytics.trackEvent("issue", "create", "create issue on issues list", 1)
            @.loadIssues()

        @scope.$on "assigned-to:changed", =>
            @.generateFilters()
            if @.isFilterDataTypeSelected('assigned_to') ||\
                @.isFilterDataTypeSelected('role') ||\
                @.isOrderedBy('assigned_to') || @.isOrderedBy('modified')
                    @.loadIssues()

        @scope.$on "status:changed", =>
            @.generateFilters()
            if @.isFilterDataTypeSelected('status') ||\
                @.isOrderedBy('status') || @.isOrderedBy('modified')
                    @.loadIssues()

    toggleShowTags: ->
        @rs.issues.storeIssuesShowTags(@scope.projectId, @showTags)

    isOrderedBy: (fieldName) ->
        pattern = new RegExp("-*"+fieldName)
        return pattern.test(@location.search().order_by)

    changeQ: (q) ->
        @.unselectFilter("page")
        @.replaceFilter("q", q)
        @.loadIssues()
        @.generateFilters()

    removeFilter: (filter) ->
        @.unselectFilter("page")
        @.unselectFilter(filter.dataType, filter.id, false, filter.mode)
        @.loadIssues()
        @.generateFilters()

    addFilter: (newFilter) ->
        @.unselectFilter("page")
        @.selectFilter(newFilter.category.dataType, newFilter.filter.id, false, newFilter.mode)
        @.loadIssues()
        @.generateFilters()

    selectCustomFilter: (customFilter) ->
        orderBy = @location.search().order_by

        if orderBy
            customFilter.filter.order_by = orderBy

        @.unselectFilter("page")
        @.replaceAllFilters(customFilter.filter)
        @.loadIssues()
        @.generateFilters()

    removeCustomFilter: (customFilter) ->
        @filterRemoteStorageService.getFilters(@scope.projectId, @.myFiltersHashSuffix).then (userFilters) =>
            delete userFilters[customFilter.id]
            @filterRemoteStorageService.storeFilters(@scope.projectId, userFilters, @.myFiltersHashSuffix).then(@.generateFilters)

    isFilterDataTypeSelected: (filterDataType) ->
        for filter in @.selectedFilters
            if (filter['dataType'] == filterDataType)
                return true
        return false

    saveCustomFilter: (name) ->
        filters = {}
        urlfilters = @location.search()

        for key in @.filterCategories
            excludeKey = @.excludePrefix.concat(key)
            filters[key] = urlfilters[key]
            filters[excludeKey] = urlfilters[excludeKey]

        @filterRemoteStorageService.getFilters(@scope.projectId, @.myFiltersHashSuffix).then (userFilters) =>
            userFilters[name] = filters

            @filterRemoteStorageService.storeFilters(@scope.projectId, userFilters, @.myFiltersHashSuffix).then(@.generateFilters)

    getQueryParams: () ->
        return _.pick(_.clone(@location.search()), @.validQueryParams)

    generateFilters: ->
        urlfilters = @.getQueryParams()
        @.storeFilters(@params.pslug, urlfilters, @.filtersHashSuffix)

        loadFilters = {}
        loadFilters.project = @scope.projectId
        loadFilters.q = urlfilters.q

        for key in @.filterCategories
            excludeKey = @.excludePrefix.concat(key)
            loadFilters[key] = urlfilters[key]
            loadFilters[excludeKey] = urlfilters[excludeKey]

        return @q.all([
            @rs.issues.filtersData(loadFilters),
            @filterRemoteStorageService.getFilters(@scope.projectId, @.myFiltersHashSuffix)
        ]).then (result) =>
            data = result[0]
            customFiltersRaw = result[1]
            dataCollection = {}

            dataCollection.status = _.map data.statuses, (it) ->
                it.id = it.id.toString()

                return it
            dataCollection.type = _.map data.types, (it) ->
                it.id = it.id.toString()

                return it
            dataCollection.severity = _.map data.severities, (it) ->
                it.id = it.id.toString()

                return it
            dataCollection.priority = _.map data.priorities, (it) ->
                it.id = it.id.toString()

                return it
            dataCollection.tags = _.map data.tags, (it) ->
                it.id = it.name

                return it

            tagsWithAtLeastOneElement = _.filter dataCollection.tags, (tag) ->
                return tag.count > 0

            dataCollection.assigned_to = _.map data.assigned_to, (it) ->
                if it.id
                    it.id = it.id.toString()
                else
                    it.id = "null"

                it.name = it.full_name || "Unassigned"

                return it
            dataCollection.owner = _.map data.owners, (it) ->
                it.id = it.id.toString()
                it.name = it.full_name

                return it
            dataCollection.role = _.map data.roles, (it) ->
                if it.id
                    it.id = it.id.toString()
                else
                    it.id = "null"

                it.name = it.name || "Unassigned"

                return it

            @.selectedFilters = []

            for key in @.filterCategories
                excludeKey = @.excludePrefix.concat(key)
                if loadFilters[key]
                    selected = @.formatSelectedFilters(key, dataCollection[key], loadFilters[key])
                    @.selectedFilters = @.selectedFilters.concat(selected)
                if loadFilters[excludeKey]
                    selected = @.formatSelectedFilters(key, dataCollection[key], loadFilters[excludeKey], "exclude")
                    @.selectedFilters = @.selectedFilters.concat(selected)

            @.filterQ = loadFilters.q

            @.filters = [
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.TYPE"),
                    dataType: "type",
                    content: dataCollection.type
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.SEVERITY"),
                    dataType: "severity",
                    content: dataCollection.severity
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.PRIORITIES"),
                    dataType: "priority",
                    content: dataCollection.priority
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.STATUS"),
                    dataType: "status",
                    content: dataCollection.status
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.TAGS"),
                    dataType: "tags",
                    content: dataCollection.tags,
                    hideEmpty: true,
                    totalTaggedElements: tagsWithAtLeastOneElement.length
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.ASSIGNED_TO"),
                    dataType: "assigned_to",
                    content: dataCollection.assigned_to
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.ROLE"),
                    dataType: "role",
                    content: dataCollection.role
                },
                {
                    title: @translate.instant("COMMON.FILTERS.CATEGORIES.CREATED_BY"),
                    dataType: "owner",
                    content: dataCollection.owner
                }
            ]

            @.customFilters = []
            _.forOwn customFiltersRaw, (value, key) =>
                @.customFilters.push({id: key, name: key, filter: value})

    initializeSubscription: ->
        routingKey = "changes.project.#{@scope.projectId}.issues"
        @events.subscribe @scope, routingKey, debounceLeading(500, (message) =>
            @.loadIssues())

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.is_issues_activated
            @errorHandlingService.permissionDenied()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)

        @scope.issueStatusById = groupBy(project.issue_statuses, (x) -> x.id)
        @scope.issueStatusList = _.sortBy(project.issue_statuses, "order")
        @scope.severityById = groupBy(project.severities, (x) -> x.id)
        @scope.severityList = _.sortBy(project.severities, "order")
        @scope.priorityById = groupBy(project.priorities, (x) -> x.id)
        @scope.priorityList = _.sortBy(project.priorities, "order")
        @scope.issueTypes = _.sortBy(project.issue_types, "order")
        @scope.issueTypeById = groupBy(project.issue_types, (x) -> x.id)

        return project

    # We need to guarantee that the last petition done here is the finally used
    # When searching by text loadIssues can be called fastly with different parameters and
    # can be resolved in a different order than generated
    # We count the requests made and only if the callback is for the last one data is updated
    loadIssuesRequests: 0
    loadIssues: =>
        params = @location.search()

        promise = @rs.issues.list(@scope.projectId, params)
        @.loadIssuesRequests += 1
        promise.index = @.loadIssuesRequests
        promise.then (data) =>
            if promise.index == @.loadIssuesRequests
                @scope.issues = data.models
                @scope.page = data.current
                @scope.count = data.count
                @scope.paginatedBy = data.paginatedBy

            return data

        return promise

    loadInitialData: ->
        project = @.loadProject()

        @.fillUsersAndRoles(project.members, project.roles)
        @.initializeSubscription()
        @.generateFilters()

        if @rs.issues.getIssuesShowTags(@scope.projectId) == false
            @showTags = false

        return @.loadIssues()

    # Functions used from templates
    addNewIssue: ->
        project = @projectService.project.toJS()
        @rootscope.$broadcast("genericform:new", {
            'objType': 'issue',
            'project': project
        })

    addIssuesInBulk: ->
        project = @projectService.project.toJS()
        @rootscope.$broadcast("issueform:bulk", project.id)

    getIssuesOrderBy: ->
        if _.isString(@location.search().order_by)
            return @location.search().order_by
        else
            return "created_date"

module.controller("IssuesController", IssuesController)

#############################################################################
## Issues Pagination Directive
#############################################################################

IssuesPaginationDirective = ($log, $location, $template, $compile) ->
    ## Issues Pagination
    template = $template.get("issue/issue-paginator.html", true)

    linkPagination = ($scope, $el, $attrs, $ctrl) ->
        # Constants
        afterCurrent = 2
        beforeCurrent = 4
        atBegin = 2
        atEnd = 2

        $pagEl = $el.find(".issues-paginator")

        getNumPages = ->
            numPages = $scope.count / $scope.paginatedBy
            if parseInt(numPages, 10) < numPages
                numPages = parseInt(numPages, 10) + 1
            else
                numPages = parseInt(numPages, 10)

            return numPages

        renderPagination = ->
            numPages = getNumPages()

            if numPages <= 1
                $pagEl.hide()
                return
            $pagEl.show()

            pages = []
            options = {}
            options.pages = pages
            options.showPrevious = ($scope.page > 1)
            options.showNext = not ($scope.page == numPages)

            cpage = $scope.page

            for i in [1..numPages]
                if i == (cpage + afterCurrent) and numPages > (cpage + afterCurrent + atEnd)
                    pages.push({classes: "dots", type: "dots"})
                else if i == (cpage - beforeCurrent) and cpage > (atBegin + beforeCurrent)
                    pages.push({classes: "dots", type: "dots"})
                else if i > (cpage + afterCurrent) and i <= (numPages - atEnd)
                else if i < (cpage - beforeCurrent) and i > atBegin
                else if i == cpage
                    pages.push({classes: "active", num: i, type: "page-active"})
                else
                    pages.push({classes: "page", num: i, type: "page"})


            html = template(options)
            html = $compile(html)($scope)

            $pagEl.html(html)

        $scope.$watch "issues", (value) ->
            # Do nothing if value is not logical true
            return if not value

            renderPagination()

        $el.on "click", ".issues-paginator a.next", (event) ->
            event.preventDefault()

            $scope.$apply ->
                $ctrl.selectFilter("page", $scope.page + 1)
                $ctrl.loadIssues()

        $el.on "click", ".issues-paginator a.previous", (event) ->
            event.preventDefault()
            $scope.$apply ->
                $ctrl.selectFilter("page", $scope.page - 1)
                $ctrl.loadIssues()

        $el.on "click", ".issues-paginator li.page > a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            pagenum = target.data("pagenum")

            $scope.$apply ->
                $ctrl.selectFilter("page", pagenum)
                $ctrl.loadIssues()

    ## Issues Link
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkPagination($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgIssuesPagination", ["$log", "$tgLocation", "$tgTemplate", "$compile", IssuesPaginationDirective])

#############################################################################
## Issues Ordering Directive
#############################################################################

IssuesOrderingDirective = ($log, $location, $template, $compile) ->
    ## Issues Filters
    linkOrdering = ($scope, $el, $attrs, $ctrl) ->
        # Draw the arrow the first time

        currentOrder = $ctrl.getIssuesOrderBy()

        if currentOrder
            icon = if startswith(currentOrder, "-") then "icon-arrow-up" else "icon-arrow-down"
            colHeadElement = $el.find(".row.title > div[data-fieldname='#{trim(currentOrder, "-")}']")

            svg = colHeadElement.find('svg')

            svg.addClass(icon)
            $compile(colHeadElement.contents())($scope)

        $el.on "click", ".row.title > div:not(.skip-order)", (event) ->
            event.preventDefault();
            target = angular.element(event.currentTarget)

            currentOrder = $ctrl.getIssuesOrderBy()
            newOrder = target.data("fieldname")

            if newOrder == 'total_voters' and currentOrder != "-total_voters"
                currentOrder = "total_voters"
            finalOrder = if currentOrder == newOrder then "-#{newOrder}" else newOrder

            $scope.$apply ->
                $ctrl.replaceFilter("order_by", finalOrder)

                if $ctrl.filtersHashSuffix
                    urlfilters = $ctrl.getQueryParams()
                    $ctrl.storeFilters($ctrl.params.pslug, urlfilters, $ctrl.filtersHashSuffix)

                $ctrl.loadIssues().then ->
                    # Update the arrow
                    $el.find('.row.title svg').removeClass()
                    colHeadElement = $el.find(".row.title > div[data-fieldname='#{trim(finalOrder, "-")}']")
                    icon = if startswith(finalOrder, "-") then "icon-arrow-up" else "icon-arrow-down"

                    colHeadElement.find('svg').addClass(icon)

                    $compile(target.contents())($scope)

    ## Issues Link
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkOrdering($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgIssuesOrdering", ["$log", "$tgLocation", "$tgTemplate", "$compile", IssuesOrderingDirective])

#############################################################################
## Issue status Directive (popover for change status)
#############################################################################

IssueStatusInlineEditionDirective = ($repo, $template, $rootscope) ->
    ###
    Print the status of an Issue and a popover to change it.
    - tg-issue-status-inline-edition: The issue

    Example:

      div.status(tg-issue-status-inline-edition="issue")
        a.issue-status(href="")

    NOTE: This directive need 'issueStatusById' and 'project'.
    ###
    selectionTemplate = $template.get("issue/issue-status-inline-edition-selection.html", true)

    updateIssueStatus = ($el, issue, issueStatusById) ->
        issueStatusDomParent = $el.find(".issue-status")
        issueStatusDom = $el.find(".issue-status .issue-status-bind")

        status = issueStatusById[issue.status]

        if status
            issueStatusDom.text(status.name)
            issueStatusDom.prop("title", status.name)
            issueStatusDomParent.css('color', status.color)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        issue = $scope.$eval($attrs.tgIssueStatusInlineEdition)

        $el.on "click", ".issue-status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $el.find(".pop-status").popover().open()

        $el.on "click", ".status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)

            issue.status = target.data("status-id")
            $el.find(".pop-status").popover().close()
            updateIssueStatus($el, issue, $scope.issueStatusById)

            attachments = issue.attachments

            $scope.$apply () ->
                $repo.save(issue).then (response) ->
                    issue.attachments = attachments
                    issue._isModified = false
                    issue._attrs = _.extend(issue.getAttrs(), issue)
                    issue._modifiedAttrs = {}

                    $rootscope.$broadcast("status:changed", response)

        taiga.bindOnce $scope, "project", (project) ->
            $el.append(selectionTemplate({ 'statuses':  project.issue_statuses }))
            updateIssueStatus($el, issue, $scope.issueStatusById)

            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_issue") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$watch $attrs.tgIssueStatusInlineEdition, (val) =>
            updateIssueStatus($el, val, $scope.issueStatusById)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgIssueStatusInlineEdition", ["$tgRepo", "$tgTemplate", "$rootScope",
                                                IssueStatusInlineEditionDirective])


#############################################################################
## Issue assigned to Directive
#############################################################################

IssueAssignedToInlineEditionDirective = ($repo, $rootscope, $translate, avatarService, $lightboxFactory) ->
    template = _.template("""
    <img style="background-color: <%- bg %>" src="<%- imgurl %>" alt="<%- name %>"/>
    """)

    link = ($scope, $el, $attrs) ->
        updateIssue = (issue) ->
            ctx = {
                name: $translate.instant("COMMON.ASSIGNED_TO.NOT_ASSIGNED"),
                imgurl: "/#{window._version}/images/unnamed.png"
            }

            member = $scope.usersById[issue.assigned_to]

            avatar = avatarService.getAvatar(member)
            ctx.imgurl = avatar.url
            ctx.bg = null

            if member
                ctx.name = member.full_name_display
                ctx.bg = avatar.bg

            $el.find(".avatar").html(template(ctx))
            $el.find(".issue-assignedto").attr('title', ctx.name)

        $ctrl = $el.controller()
        issue = $scope.$eval($attrs.tgIssueAssignedToInlineEdition)
        updateIssue(issue)

        $el.on "click", ".issue-assignedto", (event) ->
            onClose = (assignedUsers) =>
                issue.assigned_to = assignedUsers.pop() || null
                attachments = issue.attachments
                $repo.save(issue).then ->
                    issue.attachments = attachments
                    issue._isModified = false
                    issue._attrs = _.extend(issue.getAttrs(), issue)
                    issue._modifiedAttrs = {}

                    updateIssue(issue)
                    $rootscope.$broadcast("assigned-to:changed", issue)

            $lightboxFactory.create(
                'tg-lb-select-user',
                {
                    "class": "lightbox lightbox-select-user",
                },
                {
                    "currentUsers": [issue.assigned_to],
                    "activeUsers": $scope.activeUsers,
                    "onClose": onClose,
                    "single": true,
                    "lbTitle": $translate.instant("COMMON.ASSIGNED_USERS.ADD"),
                }
            )

        taiga.bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_issue") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$watch $attrs.tgIssueAssignedToInlineEdition, (val) ->
            updateIssue(val)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgIssueAssignedToInlineEdition", ["$tgRepo", "$rootScope", "$translate", "tgAvatarService",
                                                    "tgLightboxFactory", IssueAssignedToInlineEditionDirective])
