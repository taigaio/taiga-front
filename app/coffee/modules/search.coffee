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
# File: modules/search.coffee
###

taiga = @.taiga

groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
mixOf = @.taiga.mixOf
debounceLeading = @.taiga.debounceLeading
trim = @.taiga.trim
debounce = @.taiga.debounce

module = angular.module("taigaSearch", [])


#############################################################################
## Search Controller
#############################################################################

class SearchController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "$appTitle",
        "$tgNavUrls"
    ]

    constructor: (@scope, @repo, @rs, @params, @q, @location, @appTitle, @navUrls) ->
        @scope.sectionName = "Search"

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set("Search")

        promise.then null, @.onInitialDataError.bind(@)

        # Search input watcher
        @scope.searchTerm = ""
        loadSearchData = debounceLeading(100, (t) => @.loadSearchData(t))

        @scope.$watch "searchTerm", (term) =>
            if term
                loadSearchData(term)

    loadFilters: ->
        defered = @q.defer()
        defered.resolve()
        return defered.promise

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.issueStatusById = groupBy(project.issue_statuses, (x) -> x.id)
            @scope.taskStatusById = groupBy(project.task_statuses, (x) -> x.id)
            @scope.severityById = groupBy(project.severities, (x) -> x.id)
            @scope.priorityById = groupBy(project.priorities, (x) -> x.id)
            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            @scope.usStatusById = groupBy(project.us_statuses, (x) -> x.id)
            return project

    loadSearchData: (term) ->
        promise = @rs.search.do(@scope.projectId, term).then (data) =>
            @scope.searchResults = data
            return data

        return promise

    loadInitialData: ->
        return @.loadProject().then (project) =>
            @scope.projectId = project.id
            @.fillUsersAndRoles(project.users, project.roles)

module.controller("SearchController", SearchController)


#############################################################################
## Search box directive
#############################################################################

SearchBoxDirective = (projectService, $lightboxService, $navurls, $location, $route)->
    link = ($scope, $el, $attrs) ->
        project = null

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            text = $el.find("#search-text").val()

            url = $navurls.resolve("project-search", {project: project.get("slug")})

            $lightboxService.close($el)
            $scope.$apply ->
                $location.path(url)
                $location.search("text", text).path(url)
                $route.reload()

        openLightbox = () ->
            project = projectService.project

            $lightboxService.open($el)

        $el.on "submit", "form", submit

        openLightbox()

    return {
        templateUrl: "search/lightbox-search.html",
        link:link
    }

SearchBoxDirective.$inject = [
    "tgProjectService",
    "lightboxService",
    "$tgNavUrls",
    "$tgLocation",
    "$route"
]

module.directive("tgSearchBox", SearchBoxDirective)


#############################################################################
## Search Directive
#############################################################################

SearchDirective = ($log, $compile, $templatecache, $routeparams, $location) ->
    linkTable = ($scope, $el, $attrs, $ctrl) ->
        tabsDom = $el.find("section.search-filter")
        lastSeatchResults = null

        getActiveSection = (data) ->
            maxVal = 0
            selectedSectionName = null
            selectedSectionData = null

            for name, value of data
                continue if name == "count"
                if value.length > maxVal
                    maxVal = value.length
                    selectedSectionName = name
                    selectedSectionData = value

            if maxVal == 0
                return {name: "userstories", value: []}

            return {name:selectedSectionName, value: selectedSectionData}

        renderFilterTabs = (data) ->
            for name, value of data
                continue if name == "count"
                tabsDom.find("li.#{name} .num").html(value.length)

        markSectionTabActive = (section) ->
            # Mark as active the item with max amount of results
            tabsDom.find("a.active").removeClass("active")
            tabsDom.find("li.#{section.name} a").addClass("active")

        templates = {
            issues: $templatecache.get("search-issues")
            tasks: $templatecache.get("search-tasks")
            userstories: $templatecache.get("search-userstories")
            wikipages: $templatecache.get("search-wikipages")
        }

        renderTableContent = (section) ->
            oldElements = $el.find(".search-result-table").children()
            oldScope = oldElements.scope()

            if oldScope
                oldScope.$destroy()
                oldElements.remove()

            scope = $scope.$new()
            scope[section.name] = section.value

            template = angular.element.parseHTML(trim(templates[section.name]))
            element = $compile(template)(scope)
            $el.find(".search-result-table").html(element)

        $scope.$watch "searchResults", (data) ->
            lastSeatchResults = data
            activeSection = getActiveSection(data)
            renderFilterTabs(data)
            renderTableContent(activeSection)
            markSectionTabActive(activeSection)

        $scope.$watch "searchTerm", (searchTerm) ->
            $location.search("text", searchTerm) if searchTerm

        $el.on "click", ".search-filter li > a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            sectionName = target.parent().data("name")
            sectionData = lastSeatchResults[sectionName]

            section = {
                name: sectionName,
                value: sectionData
            }

            $scope.$apply ->
                renderTableContent(section)
                markSectionTabActive(section)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkTable($scope, $el, $attrs, $ctrl)

        searchText = $routeparams.text
        $scope.$watch "projectId", (projectId) ->
            $scope.searchTerm =  searchText if projectId?

    return {link:link}

module.directive("tgSearch", ["$log", "$compile", "$templateCache", "$routeParams", "$tgLocation",
                              SearchDirective])
