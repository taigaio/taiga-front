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
# File: modules/issues.coffee
###

taiga = @.taiga
mixOf = @.taiga.mixOf

module = angular.module("taigaIssues")

#############################################################################
## Issues Controller
#############################################################################

class IssuesController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q) ->
        @scope.sprintId = @params.id
        @scope.page = @params.page or 1

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

    loadFilters: ->
        defered = @q.defer()
        defered.resolve()
        return defered.promise

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.points = _.sortBy(project.points, "order")
            @scope.taskStatusList = _.sortBy(project.task_statuses, "order")
            @scope.usStatusList = _.sortBy(project.us_statuses, "order")
            return project

    loadIssues: ->
        filters = {page: @scope.page}
        promise = @rs.issues.list(@scope.projectId, filters).then (data) =>
            console.log "loadIssues:", data
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

module.controller("IssuesController", IssuesController)

#############################################################################
## Issues Controller
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

    # Constants
    template = _.template(paginatorTemplate)

    linkPagination = ($scope, $el, $attrs, $ctrl) ->
        # Constants
        afterCurrent = 5
        beforeCurrent = 5
        atBegin = 2
        atEnd = 2

        $pagEl = $el.find("section.issues-paginator")

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
                $scope.page += 1
                $location.noreload($scope).search("page", $scope.page)
                $ctrl.loadIssues()

        $el.on "click", ".issues-paginator a.previous", (event) ->
            event.preventDefault()
            $scope.$apply ->
                $scope.page -= 1
                $location.noreload($scope).search("page", $scope.page)
                $ctrl.loadIssues()


    #########################
    ## Issues Link
    #########################

    link = ($scope, $el, $attrs) ->
        console.log "IssuesDirective:link"
        $ctrl = $el.controller()
        linkPagination($scope, $el, $attrs, $ctrl)

    return {link:link}


module.directive("tgIssues", ["$log", "$tgLocation", IssuesDirective])
