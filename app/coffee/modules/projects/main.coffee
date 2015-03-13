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
        "$q",
        "$tgResources",
        "$rootScope",
        "$tgNavUrls",
        "$tgAuth",
        "$tgLocation",
        "$appTitle",
        "$projectUrl",
        "tgLoader"
    ]

    constructor: (@scope, @q, @rs, @rootscope, @navUrls, @auth, @location, @appTitle, @projectUrl,
                  tgLoader) ->
        @appTitle.set("Projects")

        if !@auth.isAuthenticated()
            @location.path(@navUrls.resolve("login"))

        @.user = @auth.getUser()

        @.projects = []
        promise = @.loadInitialData()

        promise.then () =>
            @scope.$emit("projects:loaded", @.projects)

        promise.then null, @.onInitialDataError.bind(@)

        # Finally
        promise.finally tgLoader.pageLoaded

    loadInitialData: ->
        return @rs.projects.listByMember(@rootscope.user?.id).then (projects) =>
            @.projects = {'recents': projects.slice(0, 8), 'all': projects}
            for project in projects
                project.url = @projectUrl.get(project)

            return projects

    newProject: ->
        @rootscope.$broadcast("projects:create")

    logout: ->
        @auth.logout()
        @location.path(@navUrls.resolve("login"))

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
        "$tgLocation",
        "$tgNavUrls"
    ]

    constructor: (@scope, @rs, @repo, @params, @q, @rootscope, @appTitle, @location, @navUrls) ->
        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set(@scope.project.name)
            @scope.$emit("regenerate:project-pagination")

        promise.then null, @.onInitialDataError.bind(@)

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadPageData())
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
        prevBtn = $el.find(".v-pagination-previous")
        nextBtn = $el.find(".v-pagination-next")
        container = $el.find("ul")

        pageSize = 0
        containerSize = 0

        render  = ->
            pageSize = $el.find(".v-pagination-list").height()

            if container.find("li").length
                if hasPagination()
                    if hasNextPage()
                        visible(nextBtn)
                    else
                        hide(nextBtn)

                    if hasPrevPage()
                        visible(prevBtn)
                    else
                        hide(prevBtn)
                else
                    remove()
            else
                remove()

        hasPagination = ->
            containerSize = container.height()

            return containerSize > pageSize

        hasPrevPage = (top) ->
            if !top?
                top = -parseInt(container.css('top'), 10) || 0

            return top != 0

        hasNextPage = (top) ->
            containerSize = container.height()

            if !top
                top = -parseInt(container.css('top'), 10) || 0

            return containerSize > pageSize && top + pageSize < containerSize

        nextPage = (callback) ->
            top = parseInt(container.css('top'), 10)
            newTop = top - pageSize

            lastLi = $el.find(".v-pagination-list li:last-child")
            maxTop = -((lastLi.position().top + lastLi.outerHeight()) - pageSize)

            newTop = maxTop if newTop < maxTop

            container.animate({"top": newTop}, callback)

            return newTop

        prevPage = (callback) ->
            top = parseInt(container.css('top'), 10)

            newTop = top + pageSize

            newTop = 0 if newTop > 0

            container.animate({"top": newTop}, callback)

            return newTop

        visible = (element) ->
            element.css('visibility', 'visible')

        hide = (element) ->
            element.css('visibility', 'hidden')

        checkButtonVisibility = () ->

        remove = () ->
            container.css('top', 0)
            hide(prevBtn)
            hide(nextBtn)

        $el.on "click", ".v-pagination-previous", (event) ->
            event.preventDefault()

            if container.is(':animated')
                return

            visible(nextBtn)

            newTop = prevPage()

            if !hasPrevPage(newTop)
                hide(prevBtn)

        $el.on "click", ".v-pagination-next", (event) ->
            event.preventDefault()

            if container.is(':animated')
                return

            visible(prevBtn)

            newTop = -nextPage()

            if !hasNextPage(newTop)
                hide(nextBtn)

        $scope.$on "regenerate:project-pagination", ->
            remove()
            render()

        $(window).on "resize.projects-pagination", render

        $scope.$on "$destroy", ->
            $(window).off "resize.projects-pagination"

    return {
        link: link
    }

module.directive("tgProjectsPagination", ['$timeout', ProjectsPaginationDirective])

ProjectsListDirective = ($compile, $template) ->
    template = $template.get('project/project-list.html', true)

    link = ($scope, $el, $attrs, $ctrls) ->
        render = (projects) ->
            $el.html($compile(template({projects: projects}))($scope))
            $scope.$emit("regenerate:project-pagination")

        $scope.$on "projects:loaded", (ctx, projects) ->
            render(projects.all) if projects.all?

    return {
        link: link
    }

module.directive("tgProjectsList", ["$compile", "$tgTemplate", ProjectsListDirective])
