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
# File: modules/issues/list.coffee
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
        "$appTitle",
        "$tgNavUrls",
        "$tgEvents",
        "$tgAnalytics",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @urls, @params, @q, @location, @appTitle,
                  @navUrls, @events, @analytics, tgLoader) ->
        @scope.sectionName = "Issues"
        @scope.filters = {}

        if _.isEmpty(@location.search())
            filters = @rs.issues.getFilters(@params.pslug)
            filters.page = 1
            @location.search(filters)
            @location.replace()
            return

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            @appTitle.set("Issues - " + @scope.project.name)

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

        # Finally
        promise.finally tgLoader.pageLoaded

        @scope.$on "issueform:new:success", =>
            @analytics.trackEvent("issue", "create", "create issue on issues list", 1)
            @.loadIssues()
            @.loadFilters()


    initializeSubscription: ->
        routingKey = "changes.project.#{@scope.projectId}.issues"
        @events.subscribe @scope, routingKey, (message) =>
            @.loadIssues()

    storeFilters: ->
        @rs.issues.storeFilters(@params.pslug, @location.search())

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
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

            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            return project

    getUrlFilters: ->
        filters = _.pick(@location.search(), "page", "tags", "statuses", "types",
                                             "q", "severities", "priorities",
                                             "assignedTo", "createdBy", "orderBy")
        filters.page = 1 if not filters.page
        return filters

    getUrlFilter: (name) ->
        filters = _.pick(@location.search(), name)
        return filters[name]

    loadMyFilters: ->
        return @rs.issues.getMyFilters(@scope.projectId).then (filters) =>
            return _.map filters, (value, key) =>
                return {id: key, name: key, type: "myFilters", selected: false}

    removeNotExistingFiltersFromUrl: ->
        currentSearch = @location.search()
        urlfilters = @.getUrlFilters()

        for filterName, filterValue of urlfilters
            if filterName == "page" or filterName == "orderBy" or filterName == "q"
                continue

            if filterName == "tags"
                splittedValues = _.map("#{filterValue}".split(","))
            else
                splittedValues = _.map("#{filterValue}".split(","), (x) -> if x == "null" then null else parseInt(x))

            existingValues = _.intersection(splittedValues, _.map(@scope.filters[filterName], "id"))
            if splittedValues.length != existingValues.length
                @location.search(filterName, existingValues.join())

        if currentSearch != @location.search()
           @location.replace()

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

    loadFilters: ->
        urlfilters = @.getUrlFilters()

        if urlfilters.q
            @scope.filtersQ = urlfilters.q

        # Load My Filters
        promise = @.loadMyFilters().then (myFilters) =>
            @scope.filters.myFilters = myFilters
            return myFilters

        # Load default filters data
        promise = promise.then =>
            return @rs.issues.filtersData(@scope.projectId)

        # Format filters and set them on scope
        return promise.then (data) =>
            usersFiltersFormat = (users, type, unknownOption) =>
                reformatedUsers = _.map users, (t) =>
                    return {
                        id: t[0],
                        count: t[1],
                        type: type
                        name: if t[0] then @scope.usersById[t[0]].full_name_display else unknownOption
                    }
                unknownItem = _.remove(reformatedUsers, (u) -> not u.id)
                reformatedUsers = _.sortBy(reformatedUsers, (u) -> u.name.toUpperCase())
                if unknownItem.length > 0
                    reformatedUsers.unshift(unknownItem[0])
                return reformatedUsers

            choicesFiltersFormat = (choices, type, byIdObject) =>
                _.map choices, (t) ->
                    return {
                        id: t[0],
                        name: byIdObject[t[0]].name,
                        color: byIdObject[t[0]].color,
                        count: t[1],
                        type: type}

            tagsFilterFormat = (tags) =>
                return _.map tags, (t) =>
                    return {
                        id: t[0],
                        name: t[0],
                        color: @scope.project.tags_colors[t[0]],
                        count: t[1],
                        type: "tags"
                    }

            # Build filters data structure
            @scope.filters.statuses = choicesFiltersFormat(data.statuses, "statuses", @scope.issueStatusById)
            @scope.filters.severities = choicesFiltersFormat(data.severities, "severities", @scope.severityById)
            @scope.filters.priorities = choicesFiltersFormat(data.priorities, "priorities", @scope.priorityById)
            @scope.filters.assignedTo = usersFiltersFormat(data.assigned_to, "assignedTo", "Unassigned")
            @scope.filters.createdBy = usersFiltersFormat(data.created_by, "createdBy", "Unknown")
            @scope.filters.types = choicesFiltersFormat(data.types, "types", @scope.issueTypeById)
            @scope.filters.tags = tagsFilterFormat(data.tags)

            @.removeNotExistingFiltersFromUrl()
            @.markSelectedFilters(@scope.filters, urlfilters)
            @rootscope.$broadcast("filters:loaded", @scope.filters)

    # We need to guarantee that the last petition done here is the finally used
    # When searching by text loadIssues can be called fastly with different parameters and
    # can be resolved in a different order than generated
    # We count the requests made and only if the callback is for the last one data is updated
    loadIssuesRequests: 0
    loadIssues: =>
        @scope.urlFilters = @.getUrlFilters()

        # Convert stored filters to http parameters
        # ready filters (the name difference exists
        # because of some automatic lookups and is
        # the simplest way todo it without adding
        # additional complexity to code.
        @scope.httpParams = {}
        for name, values of @scope.urlFilters
            if name == "severities"
                name = "severity"
            else if name == "orderBy"
                name = "order_by"
            else if name == "priorities"
                name = "priority"
            else if name == "assignedTo"
                name = "assigned_to"
            else if name == "createdBy"
                name = "owner"
            else if name == "statuses"
                name = "status"
            else if name == "types"
                name = "type"
            @scope.httpParams[name] = values

        promise = @rs.issues.list(@scope.projectId, @scope.httpParams)
        @.loadIssuesRequests += 1
        promise.index = @.loadIssuesRequests
        promise.then (data) =>
            if promise.index == @.loadIssuesRequests
                @scope.issues = data.models
                @scope.page = data.current
                @scope.count = data.count
                @scope.paginatedBy = data.paginatedBy
            return data

    loadInitialData: ->
        promise = @.loadProject()
        return promise.then (project) =>
            @.fillUsersAndRoles(project.users, project.roles)
            @.initializeSubscription()
            return @q.all([@.loadFilters(), @.loadIssues()])

    saveCurrentFiltersTo: (newFilter) ->
        deferred = @q.defer()
        @rs.issues.getMyFilters(@scope.projectId).then (filters) =>
            filters[newFilter] = @location.search()
            @rs.issues.storeMyFilters(@scope.projectId, filters).then =>
                deferred.resolve()
        return deferred.promise

    deleteMyFilter: (filter) ->
        deferred = @q.defer()
        @rs.issues.getMyFilters(@scope.projectId).then (filters) =>
            delete filters[filter]
            @rs.issues.storeMyFilters(@scope.projectId, filters).then =>
                deferred.resolve()
        return deferred.promise

    # Functions used from templates
    addNewIssue: ->
        @rootscope.$broadcast("issueform:new", @scope.project)

    addIssuesInBulk: ->
        @rootscope.$broadcast("issueform:bulk", @scope.projectId)


module.controller("IssuesController", IssuesController)

#############################################################################
## Issues Directive
#############################################################################

paginatorTemplate = """
<ul class="paginator">
    <% if (showPrevious) { %>
    <li class="previous">
        <a href="" class="previous next_prev_button" class="disabled">
            <span i18next="pagination.prev">Prev</span>
        </a>
    </li>
    <% } %>

    <% _.each(pages, function(item) { %>
    <li class="<%- item.classes %>">
        <% if (item.type === "page") { %>
        <a href="" data-pagenum="<%- item.num %>"><%- item.num %></a>
        <% } else if (item.type === "page-active") { %>
        <span class="active"><%- item.num %></span>
        <% } else { %>
        <span>...</span>
        <% } %>
    </li>
    <% }); %>

    <% if (showNext) { %>
    <li class="next">
        <a href="" class="next next_prev_button" class="disabled">
            <span i18next="pagination.next">Next</span>
        </a>
    </li>
    <% } %>
</ul>
"""

IssuesDirective = ($log, $location) ->
    ## Issues Pagination
    template = _.template(paginatorTemplate)

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

            $pagEl.html(template(options))

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

    ## Issues Filters
    linkOrdering = ($scope, $el, $attrs, $ctrl) ->
        # Draw the arrow the first time
        currentOrder = $ctrl.getUrlFilter("orderBy") or "created_date"
        if currentOrder
            icon = if startswith(currentOrder, "-") then "icon-caret-up" else "icon-caret-down"
            colHeadElement = $el.find(".row.title > div[data-fieldname='#{trim(currentOrder, "-")}']")
            colHeadElement.html("#{colHeadElement.html()}<span class='icon #{icon}'></span>")

        $el.on "click", ".row.title > div", (event) ->
            target = angular.element(event.currentTarget)

            currentOrder = $ctrl.getUrlFilter("orderBy")
            newOrder = target.data("fieldname")

            finalOrder = if currentOrder == newOrder then "-#{newOrder}" else newOrder

            $scope.$apply ->
                $ctrl.replaceFilter("orderBy", finalOrder)
                $ctrl.storeFilters()
                $ctrl.loadIssues().then ->
                    # Update the arrow
                    $el.find(".row.title > div > span.icon").remove()
                    icon = if startswith(finalOrder, "-") then "icon-caret-up" else "icon-caret-down"
                    target.html("#{target.html()}<span class='icon #{icon}'></span>")

    ## Issues Link
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkOrdering($scope, $el, $attrs, $ctrl)
        linkPagination($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgIssues", ["$log", "$tgLocation", IssuesDirective])


#############################################################################
## Issues Filters Directive
#############################################################################

IssuesFiltersDirective = ($log, $location, $rs, $confirm, $loading) ->
    template = _.template("""
    <% _.each(filters, function(f) { %>
        <% if (!f.selected) { %>
        <a class="single-filter"
            data-type="<%- f.type %>"
            data-id="<%- f.id %>">
            <span class="name" <% if (f.color){ %>style="border-left: 3px solid <%- f.color %>;"<% } %>>
                <%- f.name %>
            </span>
            <% if (f.count){ %>
            <span class="number"><%- f.count %></span>
            <% } %>
            <% if (f.type == "myFilters"){ %>
            <span class="icon icon-delete"></span>
            <% } %>
        </a>
        <% } %>
    <% }) %>
    <span class="new">
        <input class="hidden my-filter-name" type="text"
               placeholder="Type a descriptive filter name and press Enter" />
    </span>
    """)

    templateSelected = _.template("""
    <% _.each(filters, function(f) { %>
    <a class="single-filter selected"
       data-type="<%- f.type %>"
       data-id="<%- f.id %>">
        <span class="name" <% if (f.color){ %>style="border-left: 3px solid <%- f.color %>;"<% } %>>
            <%- f.name %>
        </span>
        <span class="icon icon-delete"></span>
    </a>
    <% }) %>
    """)


    link = ($scope, $el, $attrs) ->
        $ctrl = $el.closest(".wrapper").controller()
        selectedFilters = []

        showFilters = (title, type) ->
            $el.find(".filters-cats").hide()
            $el.find(".filter-list").removeClass("hidden")
            $el.find("h2.breadcrumb").removeClass("hidden")
            $el.find("h2 a.subfilter span.title").html(title)
            $el.find("h2 a.subfilter span.title").prop("data-type", type)

        showCategories = ->
            $el.find(".filters-cats").show()
            $el.find(".filter-list").addClass("hidden")
            $el.find("h2.breadcrumb").addClass("hidden")

        initializeSelectedFilters = (filters) ->
            selectedFilters = []
            for name, values of filters
                for val in values
                    selectedFilters.push(val) if val.selected

            renderSelectedFilters(selectedFilters)

        renderSelectedFilters = (selectedFilters) ->
            html = templateSelected({filters:selectedFilters})
            $el.find(".filters-applied").html(html)
            if selectedFilters.length > 0
                $el.find(".save-filters").show()
            else
                $el.find(".save-filters").hide()

        renderFilters = (filters) ->
            html = template({filters:filters})
            $el.find(".filter-list").html(html)

        toggleFilterSelection = (type, id) ->
            if type == "myFilters"
                $rs.issues.getMyFilters($scope.projectId).then (data) ->
                    myFilters = data
                    filters = myFilters[id]
                    filters.page = 1
                    $ctrl.replaceAllFilters(filters)
                    $ctrl.storeFilters()
                    $ctrl.loadIssues()
                    $ctrl.markSelectedFilters($scope.filters, filters)
                    initializeSelectedFilters($scope.filters)
                return null

            filters = $scope.filters[type]
            filterId = if type == 'tags' then taiga.toString(id) else id
            filter = _.find(filters, {id: filterId})

            filter.selected = (not filter.selected)

            # Convert id to null as string for properly
            # put null value on url parameters
            id = "null" if id is null

            if filter.selected
                selectedFilters.push(filter)
                $scope.$apply ->
                    $ctrl.selectFilter(type, id)
                    $ctrl.selectFilter("page", 1)
                    $ctrl.storeFilters()
                    $ctrl.loadIssues()
            else
                selectedFilters = _.reject(selectedFilters, filter)
                $scope.$apply ->
                    $ctrl.unselectFilter(type, id)
                    $ctrl.selectFilter("page", 1)
                    $ctrl.storeFilters()
                    $ctrl.loadIssues()

            renderSelectedFilters(selectedFilters)

            currentFiltersType = $el.find("h2 a.subfilter span.title").prop('data-type')
            if type == currentFiltersType
                renderFilters(_.reject(filters, "selected"))

        # Angular Watchers
        $scope.$on "filters:loaded", (ctx, filters) ->
            initializeSelectedFilters(filters)

        selectQFilter = debounceLeading 100, (value) ->
            return if value is undefined
            if value.length == 0
                $ctrl.replaceFilter("q", null)
                $ctrl.storeFilters()
            else
                $ctrl.replaceFilter("q", value)
                $ctrl.storeFilters()
            $ctrl.loadIssues()

        $scope.$watch("filtersQ", selectQFilter)

        # Dom Event Handlers
        $el.on "click", ".filters-cats > ul > li > a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            tags = $scope.filters[target.data("type")]
            renderFilters(_.reject(tags, "selected"))
            showFilters(target.attr("title"), target.data("type"))

        $el.on "click", ".filters-inner > .filters-step-cat > .breadcrumb > .back", (event) ->
            event.preventDefault()
            showCategories($el)

        $el.on "click", ".filters-applied a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            id = target.data("id") or null
            type = target.data("type")
            toggleFilterSelection(type, id)

        $el.on "click", ".filter-list .single-filter", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            target.toggleClass("active")

            id = target.data("id") or null
            type = target.data("type")

            # A saved filter can't be active
            if type == "myFilters"
                target.removeClass("active")

            toggleFilterSelection(type, id)

        $el.on "click", ".filter-list .single-filter .icon-delete", (event) ->
            event.preventDefault()
            event.stopPropagation()

            target = angular.element(event.currentTarget)
            customFilterName = target.parent().data('id')
            title = "Delete custom filter" # TODO: i18n
            message = "the custom filter '#{customFilterName}'" # TODO: i18n

            $confirm.askOnDelete(title, message).then (finish) ->
                promise = $ctrl.deleteMyFilter(customFilterName)
                promise.then ->
                    promise = $ctrl.loadMyFilters()
                    promise.then (filters) ->
                        finish()
                        $scope.filters.myFilters = filters
                        renderFilters($scope.filters.myFilters)
                    promise.then null, ->
                        finish()
                promise.then null, ->
                    finish(false)
                    $confirm.notify("error")


        $el.on "click", ".save-filters", (event) ->
            event.preventDefault()
            renderFilters($scope.filters["myFilters"])
            showFilters("My filters", "myFilters")
            $el.find('.save-filters').hide()
            $el.find('.my-filter-name').removeClass("hidden")
            $el.find('.my-filter-name').focus()

        $el.on "keyup", ".new .my-filter-name", (event) ->
            event.preventDefault()
            if event.keyCode == 13
                target = angular.element(event.currentTarget)
                newFilter = target.val()
                $loading.start($el.find(".new"))
                promise = $ctrl.saveCurrentFiltersTo(newFilter)
                promise.then ->
                    loadPromise = $ctrl.loadMyFilters()
                    loadPromise.then (filters) ->
                        $loading.finish($el.find(".new"))
                        $scope.filters.myFilters = filters

                        currentfilterstype = $el.find("h2 a.subfilter span.title").prop('data-type')
                        if currentfilterstype == "myFilters"
                            renderFilters($scope.filters.myFilters)

                        $el.find('.my-filter-name').addClass("hidden")
                        $el.find('.save-filters').show()

                    loadPromise.then null, ->
                        $loading.finish($el.find(".new"))
                        $confirm.notify("error", "Error loading custom filters")

                promise.then null, ->
                    $loading.finish($el.find(".new"))
                    $el.find(".my-filter-name").val(newFilter).focus().select()
                    $confirm.notify("error", "Filter not saved")

            else if event.keyCode == 27
                $el.find('.my-filter-name').val('')
                $el.find('.my-filter-name').addClass("hidden")
                $el.find('.save-filters').show()

    return {link:link}

module.directive("tgIssuesFilters", ["$log", "$tgLocation", "$tgResources", "$tgConfirm", "$tgLoading",
                                     IssuesFiltersDirective])


#############################################################################
## Issue status Directive (popover for change status)
#############################################################################

IssueStatusInlineEditionDirective = ($repo, popoverService) ->
    ###
    Print the status of an Issue and a popover to change it.
    - tg-issue-status-inline-edition: The issue

    Example:

      div.status(tg-issue-status-inline-edition="issue")
        a.issue-status(href="")

    NOTE: This directive need 'issueStatusById' and 'project'.
    ###
    selectionTemplate = _.template("""
    <ul class="popover pop-status">
        <% _.forEach(statuses, function(status) { %>
        <li>
            <a href="" class="status" title="<%- status.name %>" data-status-id="<%- status.id %>">
                <%- status.name %>
            </a>
        </li>
        <% }); %>
    </ul>""")

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

            $scope.$apply () ->
                $repo.save(issue).then

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

module.directive("tgIssueStatusInlineEdition", ["$tgRepo", IssueStatusInlineEditionDirective])


#############################################################################
## Issue assigned to Directive
#############################################################################

IssueAssignedToInlineEditionDirective = ($repo, $rootscope, popoverService) ->
    template = _.template("""
    <img src="<%- imgurl %>" alt="<%- name %>"/>
    <figcaption><%- name %></figcaption>
    """)

    link = ($scope, $el, $attrs) ->
        updateIssue = (issue) ->
            ctx = {name: "Unassigned", imgurl: "/images/unnamed.png"}
            member = $scope.usersById[issue.assigned_to]
            if member
                ctx.imgurl = member.photo
                ctx.name = member.full_name_display

            $el.find(".avatar").html(template(ctx))
            $el.find(".issue-assignedto").attr('title', ctx.name)

        $ctrl = $el.controller()
        issue = $scope.$eval($attrs.tgIssueAssignedToInlineEdition)
        updateIssue(issue)

        $el.on "click", ".issue-assignedto", (event) ->
            $rootscope.$broadcast("assigned-to:add", issue)

        taiga.bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_issue") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$on "assigned-to:added", (ctx, userId, updatedIssue) =>
            if updatedIssue.id == issue.id
                updatedIssue.assigned_to = userId
                $repo.save(updatedIssue)
                updateIssue(updatedIssue)

        $scope.$watch $attrs.tgIssueAssignedToInlineEdition, (val) =>
            updateIssue(val)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgIssueAssignedToInlineEdition", ["$tgRepo", "$rootScope", IssueAssignedToInlineEditionDirective])
