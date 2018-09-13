###
# Copyright (C) 2014-2018 Taiga Agile LLC
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

module = angular.module("taigaBase")


class ContribController extends taiga.Controller
    @.$inject = [
        "$rootScope",
        "$scope",
        "$routeParams",
        "$tgRepo",
        "$tgResources",
        "$tgConfirm",
        "tgProjectService"
    ]

    constructor: (@rootScope, @scope, @params, @repo, @rs, @confirm, @projectService) ->
        @scope.currentPlugin = _.head(_.filter(@rootScope.adminPlugins, {"slug": @params.plugin}))
        @scope.projectSlug = @params.pslug

        @.loadInitialData()

    loadProject: ->
        project = @projectService.project.toJS()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)
        @scope.$broadcast('project:loaded', project)
        return project

    loadInitialData: ->
        return @.loadProject()

module.controller("ContribController", ContribController)


class ContribUserSettingsController extends taiga.Controller
    @.$inject = [
        "$rootScope",
        "$scope",
        "$routeParams"
    ]

    constructor: (@rootScope, @scope, @params) ->
        @scope.currentPlugin = _.head(_.filter(@rootScope.userSettingsPlugins, {"slug": @params.plugin}))

module.controller("ContribUserSettingsController", ContribUserSettingsController)
