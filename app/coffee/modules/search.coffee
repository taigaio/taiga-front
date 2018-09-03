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
        "tgAppMetaService",
        "$tgNavUrls",
        "$translate",
        "tgErrorHandlingService",
        "tgProjectService"
    ]

    constructor: (@scope, @repo, @rs, @params, @q, @location, @appMetaService, @navUrls, @translate, @errorHandlingService, @projectService) ->
        @scope.sectionName = "Search"

        @.loadInitialData()

        title = @translate.instant("SEARCH.PAGE_TITLE", {projectName: @scope.project.name})
        description = @translate.instant("SEARCH.PAGE_DESCRIPTION", {
            projectName: @scope.project.name,
            projectDescription: @scope.project.description
        })

        @appMetaService.setAll(title, description)

        # Search input watcher
        @scope.searchTerm = null
        loadSearchData = debounceLeading(100, (t) => @.loadSearchData(t))

        bindOnce @scope, "projectId", (projectId) =>
            if !@scope.searchResults && @scope.searchTerm
                @.loadSearchData()

        @scope.$watch "searchTerm", (term) =>
            if term != undefined && @scope.projectId
                @.loadSearchData(term)

    loadFilters: ->
        defered = @q.defer()
        defered.resolve()
        return defered.promise

    loadProject: ->
        project = @projectService.project.toJS()

        @scope.project = project
        @scope.$emit('project:loaded', project)

        @scope.epicStatusById = groupBy(project.epic_statuses, (x) -> x.id)
        @scope.issueStatusById = groupBy(project.issue_statuses, (x) -> x.id)
        @scope.taskStatusById = groupBy(project.task_statuses, (x) -> x.id)
        @scope.severityById = groupBy(project.severities, (x) -> x.id)
        @scope.priorityById = groupBy(project.priorities, (x) -> x.id)
        @scope.usStatusById = groupBy(project.us_statuses, (x) -> x.id)
        return project

    loadSearchData: (term = "") ->
        @scope.loading = true

        @._loadSearchData(term).then (data) =>
            @scope.searchResults = data
            @scope.loading = false

    _loadSearchData: (term = "") ->
        @._promise.abort() if @._promise

        @._promise = @rs.search.do(@scope.projectId, term)

        return @._promise

    loadInitialData: ->
        project = @.loadProject()

        @scope.projectId = project.id
        @.fillUsersAndRoles(project.members, project.roles)

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

            $scope.$apply ->
                $lightboxService.close($el)

                $location.path(url)
                $location.search("text", text).path(url)
                $route.reload()


        openLightbox = () ->
            project = projectService.project

            $lightboxService.open($el).then () ->
                $el.find("#search-text").focus()

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

SearchDirective = ($log, $compile, $templatecache, $routeparams, $location, $analytics) ->
    linkTable = ($scope, $el, $attrs, $ctrl) ->
        applyAutoTab = true
        activeSectionName = "userstories"
        tabsDom = $el.find(".search-filter")
        currentSearchResults = null

        getActiveSection = (data) ->
            maxVal = 0
            selectedSection = {}
            selectedSection.name = "userstories"
            selectedSection.value = []

            if !applyAutoTab
                selectedSection.name = activeSectionName
                selectedSection.value = data[activeSectionName]

                return selectedSection

            if data
                for name in ["userstories", "epics", "issues", "tasks", "wikipages"]
                    value = data[name]

                    if value.length > maxVal
                        maxVal = value.length
                        selectedSection.name = name
                        selectedSection.value = value
                        break

            if maxVal == 0
                return selectedSection

            return selectedSection

        renderFilterTabs = (data) ->
            for name, value of data
                tabsDom.find("li.#{name}").show()
                tabsDom.find("li.#{name} .num").html(value.length)

        markSectionTabActive = (section) ->
            # Mark as active the item with max amount of results
            tabsDom.find("a.active").removeClass("active")
            tabsDom.find("li.#{section.name} a").addClass("active")

            applyAutoTab = false
            activeSectionName = section.name

        templates = {
            epics: $templatecache.get("search-epics")
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
            currentSearchResults = data

            return if !currentSearchResults

            activeSection = getActiveSection(data)

            renderFilterTabs(data)

            renderTableContent(activeSection)
            markSectionTabActive(activeSection)

        $scope.$watch "searchTerm", (searchTerm) ->
            $location.search("text", searchTerm) if searchTerm != undefined
            $analytics.trackPage($location.url(), "Search")

        $el.on "click", ".search-filter li > a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            sectionName = target.parent().data("name")
            sectionData = if !currentSearchResults then [] else currentSearchResults[sectionName]

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

module.directive("tgSearch", ["$log", "$compile", "$templateCache", "$routeParams", "$tgLocation", "$tgAnalytics",
                              SearchDirective])
