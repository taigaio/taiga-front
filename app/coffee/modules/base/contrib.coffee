###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
        "tgProjectService",
        "tgErrorHandlingService"
    ]

    constructor: (@rootScope, @scope, @params, @repo, @rs, @confirm, @projectService, @errorHandlingService) ->
        @scope.currentPlugin = _.head(_.filter(@rootScope.adminPlugins, {"slug": @params.plugin}))
        @scope.projectSlug = @params.pslug

        @.loadInitialData()

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.i_am_admin
            @errorHandlingService.permissionDenied()

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
