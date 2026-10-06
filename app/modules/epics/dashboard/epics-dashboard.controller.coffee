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
        @.openFilter = false
        @.filterQ = @location.search().q
        @.filters = []
        @.customFilters = []
        @.selectedFilters = []

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

                return @.loadFilterData(filterDataParams).then () =>
                    @epicsService.fetchEpics(false, filters)

    getActiveFilters: () ->
        return _.pick(_.clone(@location.search()), @.validQueryParams.concat("page"))

    reloadWithFilters: () ->
        @.unselectFilter("page")
        @epicsService.clear()

        filters = @.getActiveFilters()
        filters.project = @project.get("id")
        filterDataParams = _.omit(_.clone(filters), "page")

        return @.loadFilterData(filterDataParams).then () =>
            @epicsService.fetchEpics(false, filters)

    loadFilterData: (params) ->
        return @rs.epics.filtersData(params).then (data) =>
            @.setFiltersFromData(data)

    setFiltersFromData: (data) ->
        dataCollection = {}
        dataCollection.status = _.map(data.statuses or [], (item) ->
            _.assign({}, item, {id: _.toString(item.id)})
        )
        dataCollection.assigned_to = _.map(data.assigned_to or [], (item) ->
            _.assign({}, item, {
                id: if item.id? then _.toString(item.id) else "null"
                name: item.full_name or "Unassigned"
            })
        )
        dataCollection.owner = _.map(data.owners or [], (item) ->
            _.assign({}, item, {id: _.toString(item.id), name: item.full_name})
        )
        dataCollection.tags = _.map(data.tags or [], (item) ->
            _.assign({}, item, {id: item.name})
        )

        selectedParams = _.pick(@location.search(), @.validQueryParams)
        @.selectedFilters = []
        for key in ["status", "assigned_to", "owner", "tags"]
            if selectedParams[key]
                @.selectedFilters = @.selectedFilters.concat(
                    @.formatSelectedFilters(key, dataCollection[key], selectedParams[key])
                )
            excludeKey = "exclude_#{key}"
            if selectedParams[excludeKey]
                @.selectedFilters = @.selectedFilters.concat(
                    @.formatSelectedFilters(key, dataCollection[key], selectedParams[excludeKey], "exclude")
                )

        tagsWithAtLeastOneEpic = _.filter(dataCollection.tags, (tag) -> tag.count > 0)
        @.filters = [
            {
                title: @translate.instant("COMMON.FILTERS.CATEGORIES.STATUS")
                dataType: "status"
                content: dataCollection.status
            }
            {
                title: @translate.instant("COMMON.FILTERS.CATEGORIES.ASSIGNED_TO")
                dataType: "assigned_to"
                content: dataCollection.assigned_to
            }
            {
                title: @translate.instant("COMMON.FILTERS.CATEGORIES.CREATED_BY")
                dataType: "owner"
                content: dataCollection.owner
            }
            {
                title: @translate.instant("COMMON.FILTERS.CATEGORIES.TAGS")
                dataType: "tags"
                content: dataCollection.tags
                hideEmpty: true
                totalTaggedElements: tagsWithAtLeastOneEpic.length
            }
        ]

    canCreateEpics: () ->
        return @projectService.canEdit("add_epic")

    changeQ: (q) ->
        @.filterQ = q
        @.replaceFilter("q", q)
        @.storeCurrentFilters()
        @.reloadWithFilters()

    addFilter: (newFilter) ->
        @.selectFilter(newFilter.category.dataType, newFilter.filter.id, false, newFilter.mode)
        @.storeCurrentFilters()
        @.reloadWithFilters()

    removeFilter: (filter) ->
        @.unselectFilter(filter.dataType, filter.id, false, filter.mode)
        @.storeCurrentFilters()
        @.reloadWithFilters()

    clearFilters: () ->
        params = _.omit(_.clone(@location.search()), @.validQueryParams.concat("page"))
        @.replaceAllFilters(params)
        @.filterQ = null
        @.storeCurrentFilters()
        @.reloadWithFilters()

    storeCurrentFilters: () ->
        filters = _.pick(_.clone(@location.search()), @.validQueryParams)
        @.storeFilters(@params.pslug, filters, @.filtersHashSuffix)

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
