###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: epics.dashboard.controller.coffee
###

module = angular.module("taigaEpics")

class EpicsDashboardController
    @.$inject = [
        "$tgResources",
        "$routeParams",
        "tgErrorHandlingService"
    ]

    constructor: (@rs, @params, @errorHandlingService) ->
        @.sectionName = "Epics"
        @._loadProject()

    _loadProject: () ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            if not project.is_epics_activated
                @errorHandlingService.permissionDenied()
            @.project = project

    addNewEpic: () ->
        console.log 'Add new Epic'

module.controller("EpicsDashboardCtrl", EpicsDashboardController)
