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
debounce = @.taiga.debounce
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
        "$routeParams",
        "$q",
        "$location"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location) ->
        @scope.sprintId = @params.id
        @scope.sectionName = "Issues"
        @scope.filters = {}

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

        @scope.$on "issueform:new:succcess", =>
            @.loadIssues()
            @.loadFilters()

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project

            # TODO: add issueTypeList and issueTypeById
            @scope.issueStatusById = groupBy(project.issue_statuses, (x) -> x.id)
            @scope.issueStatusList = _.sortBy(project.issue_statuses, "order")
            @scope.severityById = groupBy(project.severities, (x) -> x.id)
            @scope.severityList = _.sortBy(project.severities, "order")
            @scope.priorityById = groupBy(project.priorities, (x) -> x.id)
            @scope.priorityList = _.sortBy(project.priorities, "order")

            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            return project

    getUrlFilters: ->
        filters = _.pick(@location.search(), "page", "tags", "statuses", "types",
                                             "subject", "severities", "priorities",
                                             "assignedTo", "orderBy")
        filters.page = 1 if not filters.page
        return filters

    getUrlFilter: (name) ->
        filters = _.pick(@location.search(), name)
        return filters[name]

    loadFilters: ->
        # This function is executed only once when page is loads and
        # it needs create all filters structure and know that
        # filters are selected from url params.
        urlfilters = @.getUrlFilters()

        if urlfilters.subject
            @scope.filtersSubject = urlfilters.subject

        return @rs.issues.filtersData(@scope.projectId).then (data) =>
            # Build selected filters (from url) fast lookup data structure
            searchdata = {}

            for name, value of _.omit(urlfilters, "page", "orderBy")
                # if name == "page" or name == "orderBy"
                #     continue
                if not searchdata[name]?
                    searchdata[name] = {}

                for val in value.split(",")
                    searchdata[name][val] = true

            isSelected = (type, id) ->
                if searchdata[type]? and searchdata[type][id]
                    return true
                return false

            # Build filters data structure
            @scope.filters.tags = _.map data.tags, (t) =>
                obj = {id:t[0], name:t[0], count: t[1], type:"tags"}
                obj.selected = true if isSelected("tags", obj.id)
                return obj

            @scope.filters.priorities = _.map data.priorities, (t) =>
                obj = {id:t[0], name:@scope.priorityById[t[0]].name, count:t[1], type:"priorities"}
                obj.selected = true if isSelected("priorities", obj.id)
                return obj

            @scope.filters.severities = _.map data.severities, (t) =>
                obj = {id:t[0], name:@scope.severityById[t[0]].name, count:t[1], type:"severities"}
                obj.selected = true if isSelected("severities", obj.id)
                return obj

            @scope.filters.assignedTo = _.map data.assigned_to, (t) =>
                obj = {id:t[0], count:t[1], type:"assignedTo"}
                if t[0]
                    obj.name = @scope.usersById[t[0]].full_name_display
                else
                    obj.name = "Unassigned"

                obj.selected = true if isSelected("assignedTo", obj.id)
                return obj

            @scope.filters.statuses = _.map data.statuses, (t) =>
                obj = {id:t[0], name:@scope.issueStatusById[t[0]].name, count:t[1], type:"statuses"}
                obj.selected = true if isSelected("statuses", obj.id)
                return obj

            @rootscope.$broadcast("filters:loaded", @scope.filters)
            return data

    loadIssues: ->
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
            else if name == "statuses"
                name = "status"
            @scope.httpParams[name] = values

        console.log "prepared filters", @scope.httpParams
        promise = @rs.issues.list(@scope.projectId, @scope.httpParams).then (data) =>
            @scope.issues = data.models
            @scope.page = data.current
            @scope.count = data.count
            @scope.paginatedBy = data.paginatedBy
            return data

        return promise

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadFilters())
                      .then(=> @.loadIssues())

    # Functions used from templates
    addNewIssue: ->
        console.log "Kakita"
        @rootscope.$broadcast("issueform:new")

    addIssuesInBulk: ->
        @rootscope.$broadcast("issueform:bulk")


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
    <li class="<%= item.classes %>">
        <% if (item.type === "page") { %>
        <a href="" data-pagenum="<%= item.num %>"><%= item.num %></a>
        <% } else if (item.type === "page-active") { %>
        <span class="active"><%= item.num %></span>
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

    #########################
    ## Issues Pagination
    #########################

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

    #########################
    ## Issues Filters
    #########################

    linkOrdering = ($scope, $el, $attrs, $ctrl) ->
        $el.on "click", ".row.title > div", (event) ->
            target = angular.element(event.currentTarget)

            currentOrder = $ctrl.getUrlFilter("orderBy")
            newOrder = target.data("fieldname")
            finalOrder = newOrder

            if currentOrder is undefined
                finalOrder = newOrder
            else
                reverse = true
                if startswith(currentOrder, "-")
                    reverse = false
                    currentOrder = trim(currentOrder, "-")

                if currentOrder == newOrder
                    finalOrder = if reverse then "-#{newOrder}" else newOrder

            $scope.$apply ->
                $ctrl.replaceFilter("orderBy", finalOrder)
                $ctrl.loadIssues()

    #########################
    ## Issues Link
    #########################

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkOrdering($scope, $el, $attrs, $ctrl)
        linkPagination($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

#############################################################################
## Issues Filters Directive
#############################################################################

IssuesFiltersDirective = ($log, $location) ->
    template = _.template("""
    <% _.each(filters, function(f) { %>
        <% if (f.selected) { %>
        <a class="single-filter active"
            data-type="<%= f.type %>"
            data-id="<%= f.id %>">
            <span class="name"><%- f.name %></span>
            <span class="number"><%- f.count %></span>
        </a>
        <% } else { %>
        <a class="single-filter"
            data-type="<%= f.type %>"
            data-id="<%= f.id %>">
            <span class="name"><%- f.name %></span>
            <span class="number"><%- f.count %></span>
        </a>
        <% } %>
    <% }) %>
    """)

    templateSelected = _.template("""
    <% _.each(filters, function(f) { %>
    <a class="single-filter selected"
       data-type="<%= f.type %>"
       data-id="<%= f.id %>">
        <span class="name"><%- f.name %></span>
        <span class="icon icon-delete"></span>
    </a>
    <% }) %>
    """)


    link = ($scope, $el, $attrs) ->
        $ctrl = $el.closest(".wrapper").controller()
        selectedFilters = []

        showFilters = (title) ->
            $el.find(".filters-cats").hide()
            $el.find(".filter-list").show()
            $el.find("h1 a.subfilter").removeClass("hidden")
            $el.find("h1 a.subfilter span.title").html(title)

        showCategories = ->
            $el.find(".filters-cats").show()
            $el.find(".filter-list").hide()
            $el.find("h1 a.subfilter").addClass("hidden")

        initializeSelectedFilters = (filters) ->
            for name, values of filters
                for val in values
                    selectedFilters.push(val) if val.selected

            renderSelectedFilters()

        renderSelectedFilters = ->
            html = templateSelected({filters:selectedFilters})
            $el.find(".filters-applied").html(html)

        renderFilters = (filters) ->
            html = template({filters:filters})
            $el.find(".filter-list").html(html)

        toggleFilterSelection = (type, id) ->
            filters = $scope.filters[type]
            filter = _.find(filters, {id:id})
            filter.selected = (not filter.selected)

            # Convert id to null as string for properly
            # put null value on url parameters
            id = "null" if id is null

            if filter.selected
                selectedFilters.push(filter)
                $scope.$apply ->
                    $ctrl.selectFilter(type, id)
                    $ctrl.selectFilter("page", 1)
                    $ctrl.loadIssues()
            else
                selectedFilters = _.reject(selectedFilters, filter)
                $scope.$apply ->
                    $ctrl.unselectFilter(type, id)
                    $ctrl.selectFilter("page", 1)
                    $ctrl.loadIssues()

            renderSelectedFilters(selectedFilters)
            renderFilters(_.reject(filters, "selected"))

        # Angular Watchers
        $scope.$on "filters:loaded", (ctx, filters) ->
            initializeSelectedFilters(filters)

        selectSubjectFilter = debounce 400, (value) ->
            return if value is undefined
            if value.length == 0
                $ctrl.replaceFilter("subject", null)
            else
                $ctrl.replaceFilter("subject", value)
            $ctrl.loadIssues()

        $scope.$watch("filtersSubject", selectSubjectFilter)

        # Dom Event Handlers
        $el.on "click", ".filters-cats > ul > li > a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            tags = $scope.filters[target.data("type")]

            renderFilters(_.reject(tags, "selected"))
            showFilters(target.attr("title"))

        $el.on "click", ".filters-inner > h1 > a.title", (event) ->
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
            if target.hasClass("active")
                target.removeClass("active")
            else
                target.addClass("active")

            id = target.data("id") or null
            type = target.data("type")
            toggleFilterSelection(type, id)

    return {link:link}

module.directive("tgIssuesFilters", ["$log", "$tgLocation", IssuesFiltersDirective])
module.directive("tgIssues", ["$log", "$tgLocation", IssuesDirective])
