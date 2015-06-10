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
# File: modules/base/contrib.coffee
###

taigaContribPlugins = @.taigaContribPlugins = @.taigaContribPlugins or []

class ContribController extends taiga.Controller
    @.$inject = [
        "$rootScope",
        "$scope",
        "$routeParams",
        "$tgRepo",
        "$tgResources",
        "$tgConfirm"
    ]

    constructor: (@rootScope, @scope, @params, @repo, @rs, @confirm) ->
        @scope.adminPlugins = _.where(@rootScope.contribPlugins, {"type": "admin"})
        @scope.currentPlugin = _.first(_.where(@scope.adminPlugins, {"slug": @params.plugin}))
        @scope.pluginTemplate = "contrib/#{@scope.currentPlugin.slug}"
        @scope.projectSlug = @params.pslug

        promise = @.loadInitialData()

        promise.then null, =>
            @confirm.notify("error")

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            @scope.projectId = project.id
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.$broadcast('project:loaded', project)
            return project

    loadInitialData: ->
        return @.loadProject()

module = angular.module("taigaBase")
module.controller("ContribController", ContribController)
