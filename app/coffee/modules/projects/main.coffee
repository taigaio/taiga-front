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
        "$tgConfig",
        "tgLoader"
    ]

    constructor: (@scope, @q, @rs, @rootscope, @navUrls, @auth, @location, @appTitle, @projectUrl, @config
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

    isFeedbackEnabled: ->
        return @config.get("feedbackEnabled")

    sendFeedback: ->
        @rootscope.$broadcast("feedback:show")

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
        promise = @.loadProject()
        promise.then(=> @.loadProjectStats())
        return promise

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            @scope.projectId = project.id
            @scope.project = project
            @scope.$emit("project:loaded", @scope.project)
            return project

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @scope.stats = stats
            return stats

module.controller("ProjectController", ProjectController)

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
