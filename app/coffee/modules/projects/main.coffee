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
# File: modules/common/attachments.coffee
###

taiga = @.taiga
module = angular.module("taigaProject")
bindOnce = @.taiga.bindOnce


class ProjectsController extends taiga.Controller
    @.$inject = [
        "$scope",
        "$tgResources",
        "$rootScope",
        "$tgNavUrls",
        "$tgAuth",
        "$tgLocation",
        "$appTitle",
        "$projectUrl",
        "tgLoader"
    ]

    constructor: (@scope, @rs, @rootscope, @navurls, @auth, @location, @appTitle, @projectUrl, @tgLoader) ->
        @appTitle.set("Projects")

        if !@auth.isAuthenticated()
            @location.path(@navurls.resolve("login"))

        @.projects = []
        @.loadInitialData()
        .then () =>
            @scope.$emit("projects:loaded")
            @tgLoader.pageLoaded()

    loadInitialData: ->
        return @rs.projects.list().then (projects) =>
            @.projects = {'recents': projects.slice(0, 8), 'all': projects.slice(8)}

            for project in projects
                project.url = @projectUrl.get(project)

    newProject: ->
        @rootscope.$broadcast("projects:create")

module.controller("ProjectsController", ProjectsController)


class ProjectController extends taiga.Controller
    @.$inject = [
        "$scope",
        "$tgResources",
        "$tgRepo",
        "$routeParams",
        "$q",
        "$rootScope",
        "$appTitle",
        "$tgLocation"
    ]

    constructor: (@scope, @rs, @repo, @params, @q, @rootscope, @appTitle, @location) ->
        @.loadInitialData()
            .then () =>
                @appTitle.set(@scope.project.name)

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        promise.then null, =>
            @location.path("/not-found")
            @location.replace()

        return promise
                .then(=> @.loadPageData())
                .then(=> @scope.$emit("project:loaded", @scope.project))

    loadPageData: ->
        return @q.all([
            @.loadProjectStats(),
            @.loadProject()])

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            return project

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @scope.stats = stats
            return stats

module.controller("ProjectController", ProjectController)


ProjectsPaginationDirective = ($timeout) ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "projects", (projects) ->
            container = nextBtn = prevBtn = null
            pageSize = 0
            containerSize = 0

            renderNextAndPrev  = ->
                if projects.length
                    pageSize = $el.find(".v-pagination-list").height()
                    containerSize = container.height()
                    if containerSize > pageSize
                        visible(nextBtn)
                    else
                        remove()
                else
                    remove()

            nextPage = (element, pageSize, callback) ->
                top = parseInt(element.css('top'), 10)
                newTop = top - pageSize

                element.animate({"top": newTop}, callback)

                return newTop

            prevPage = (element, pageSize, callback) ->
                top = parseInt(element.css('top'), 10)
                newTop = top + pageSize

                element.animate({"top": newTop}, callback)

                return newTop

            visible = (element) ->
                element.css('visibility', 'visible')

            hide = (element) ->
                element.css('visibility', 'hidden')

            remove = () ->
                container.css('top', 0)
                hide(prevBtn)
                hide(nextBtn)

            $el.on "click", ".v-pagination-previous", (event) ->
                event.preventDefault()

                if container.is(':animated')
                    return

                visible(nextBtn)

                newTop = prevPage(container, pageSize)

                if newTop == 0
                    hide(prevBtn)

            $el.on "click", ".v-pagination-next", (event) ->
                event.preventDefault()

                if container.is(':animated')
                    return

                visible(prevBtn)

                newTop = nextPage(container, pageSize)

                if -newTop + pageSize > containerSize
                    hide(nextBtn)

            $el.on "regenerate:pagination", () =>
                renderNextAndPrev()

            #wait digest end
            $timeout () =>
                prevBtn = $el.find(".v-pagination-previous")
                nextBtn = $el.find(".v-pagination-next")
                container = $el.find("ul")

                renderNextAndPrev()

    return {
        link: link,
        scope: {
            projects: "="
        }
    }

module.directive("tgProjectsPagination", ['$timeout', ProjectsPaginationDirective])
