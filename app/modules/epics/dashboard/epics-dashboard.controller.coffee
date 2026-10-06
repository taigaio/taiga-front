###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
mixOf = @.taiga.mixOf


class EpicsDashboardController extends mixOf(taiga.Controller, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$routeParams",
        "tgErrorHandlingService",
        "tgLightboxFactory",
        "lightboxService",
        "$tgConfirm",
        "tgProjectService",
        "tgEpicsService",
        "$tgResources",
        "$tgLocation",
        "$tgStorage",
        "tgAppMetaService",
        "$translate"
    ]

    filtersHashSuffix: "epics-filters"
    validQueryParams: [
        "q", "status", "exclude_status", "assigned_to", "exclude_assigned_to",
        "owner", "exclude_owner", "tags", "exclude_tags"
    ]

    constructor: (@scope, @params, @errorHandlingService, @lightboxFactory, @lightboxService,
                  @confirm, @projectService, @epicsService, @rs, @location, @storage,
                  @appMetaService, @translate) ->

        @.sectionName = "EPICS.SECTION_NAME"

        taiga.defineImmutableProperty @, 'project', () => return @projectService.project
        taiga.defineImmutableProperty @, 'epics', () => return @epicsService.epics

        @appMetaService.setfn @._setMeta.bind(this)

        return if @.applyStoredFilters(@params.pslug, @.filtersHashSuffix, @.validQueryParams)

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

                filters = @.getActiveFilters()
                filters.project = @project.get("id")
                filterDataParams = _.omit(_.clone(filters), "page")

                return @rs.epics.filtersData(filterDataParams).then () =>
                    @epicsService.fetchEpics(false, filters)

    getActiveFilters: () ->
        return _.pick(_.clone(@location.search()), @.validQueryParams.concat("page"))

    reloadWithFilters: () ->
        @.unselectFilter("page")
        @epicsService.clear()

        filters = @.getActiveFilters()
        filters.project = @project.get("id")
        filterDataParams = _.omit(_.clone(filters), "page")

        return @rs.epics.filtersData(filterDataParams).then () =>
            @epicsService.fetchEpics(false, filters)

    canCreateEpics: () ->
        return @projectService.canEdit("add_epic")

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
