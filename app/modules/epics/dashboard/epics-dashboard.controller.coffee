###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
        "tgEpicsService",
        "tgAppMetaService",
        "$translate"
    ]

    constructor: (@params, @errorHandlingService, @lightboxFactory, @lightboxService,
                  @confirm, @projectService, @epicsService, @appMetaService, @translate) ->

        @.sectionName = "EPICS.SECTION_NAME"

        taiga.defineImmutableProperty @, 'project', () => return @projectService.project
        taiga.defineImmutableProperty @, 'epics', () => return @epicsService.epics

        @appMetaService.setfn @._setMeta.bind(this)

    _setMeta: () ->
        return null if !@.project

        ctx = {
            projectName: @.project.get("name")
            projectDescription: @.project.get("description")
        }

        return {
            title: @translate.instant("EPICS.PAGE_TITLE", ctx)
            description: @translate.instant("EPICS.PAGE_DESCRIPTION", ctx)
        }

    loadInitialData: () ->
        @epicsService.clear()
        return @projectService.setProjectBySlug(@params.pslug)
            .then () =>
                if not @projectService.isEpicsDashboardEnabled()
                    return @errorHandlingService.notFound()
                if not @projectService.hasPermission("view_epics")
                    return @errorHandlingService.permissionDenied()

                return @epicsService.fetchEpics()

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
