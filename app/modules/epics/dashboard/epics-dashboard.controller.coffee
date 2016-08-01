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
        "tgResources",
        "$routeParams",
        "tgErrorHandlingService",
        "tgLightboxFactory",
        "lightboxService",
        "$tgConfirm"
    ]

    constructor: (@rs, @resources, @params, @errorHandlingService, @lightboxFactory, @lightboxService, @confirm) ->
        @.sectionName = "Epics"
        @._loadProject()
        @.createEpic = false

    _loadProject: () ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            if not project.is_epics_activated
                @errorHandlingService.permissionDenied()
            @.project = project
            @.loadEpics()

    loadEpics: () ->
        projectId = @.project.id
        return @resources.epics.list(projectId).then (epics) =>
            @.epics = epics

    _onCreateEpic: () ->
        @lightboxService.closeAll()
        @confirm.notify("success")
        @.loadEpics()

    onCreateEpic: () ->
        @lightboxFactory.create('tg-create-epic', {
            "class": "lightbox lightbox-create-epic open"
            "project": "project"
            "on-reload-epics": "reloadEpics()"
        }, {
            "project": @.project
            "reloadEpics": @._onCreateEpic.bind(this)
        })

module.controller("EpicsDashboardCtrl", EpicsDashboardController)
