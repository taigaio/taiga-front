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

taiga = @.taiga


class EpicsDashboardController
    @.$inject = [
        "$routeParams",
        "tgErrorHandlingService",
        "tgLightboxFactory",
        "lightboxService",
        "$tgConfirm",
        "tgProjectService",
        "tgEpicsService"
    ]

    constructor: (@params, @errorHandlingService, @lightboxFactory, @lightboxService,
                  @confirm, @projectService, @epicsService) ->

        @.sectionName = "EPICS.SECTION_NAME"

        taiga.defineImmutableProperty @, 'project', () => return @projectService.project
        taiga.defineImmutableProperty @, 'epics', () => return @epicsService.epics

        @._loadInitialData()

    _loadInitialData: () ->
        @epicsService.clear()
        @projectService.setProjectBySlug(@params.pslug)
            .then () =>
                if not @.project.get("is_epics_activated") or not @projectService.hasPermission("view_epics")
                    @errorHandlingService.permissionDenied()

                @epicsService.fetchEpics()

    canCreateEpics: () ->
        return @projectService.hasPermission("add_epic")

    onCreateEpic: () ->
        onCreateEpic =  () =>
            @lightboxService.closeAll()
            @confirm.notify("success")
            return # To prevent error https://docs.angularjs.org/error/$parse/isecdom?p0=onCreateEpic()

        @lightboxFactory.create('tg-create-epic', {
            "class": "lightbox lightbox-create-epic open"
            "on-create-epic": "onCreateEpic()"
        }, {
            "onCreateEpic": onCreateEpic.bind(this)
        })

angular.module("taigaEpics").controller("EpicsDashboardCtrl", EpicsDashboardController)
