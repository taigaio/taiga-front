###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/backlog/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy
debounceLeading = @.taiga.debounceLeading


module = angular.module("taigaBacklog")

#############################################################################
## Issues Filters Directive
#############################################################################

BacklogFiltersDirective = ($q, $log, $location, $template, $compile) ->
    template = $template.get("backlog/filters.html", true)
    templateSelected = $template.get("backlog/filter-selected.html", true)

    link = ($scope, $el, $attrs) ->
        currentFiltersType = ''

        $ctrl = $el.closest(".wrapper").controller()
        selectedFilters = []

        showFilters = (title, type) ->
            $el.find(".filters-cats").hide()
            $el.find(".filter-list").removeClass("hidden")
            $el.find("h2.breadcrumb").removeClass("hidden")
            $el.find("h2 a.subfilter span.title").html(title)
            $el.find("h2 a.subfilter span.title").prop("data-type", type)

            currentFiltersType = getFiltersType()

        showCategories = ->
            $el.find(".filters-cats").show()
            $el.find(".filter-list").addClass("hidden")
            $el.find("h2.breadcrumb").addClass("hidden")

        initializeSelectedFilters = () ->
            showCategories()
            selectedFilters = []

            for name, values of $scope.filters
                for val in values
                    selectedFilters.push(val) if val.selected

            renderSelectedFilters()

        renderSelectedFilters = ->
            _.map selectedFilters, (f) =>
                if f.color
                    f.style = "border-left: 3px solid #{f.color}"

            html = templateSelected({filters: selectedFilters})
            html = $compile(html)($scope)

            $el.find(".filters-applied").html(html)

        renderFilters = (filters) ->
            _.map filters, (f) =>
                if f.color
                    f.style = "border-left: 3px solid #{f.color}"

            html = template({filters:filters})
            html = $compile(html)($scope)
            $el.find(".filter-list").html(html)

        getFiltersType = () ->
            return $el.find("h2 a.subfilter span.title").prop('data-type')

        reloadUserstories = () ->
            currentFiltersType = getFiltersType()

            $q.all([$ctrl.loadUserstories(true), $ctrl.generateFilters()]).then () ->
                currentFilters = $scope.filters[currentFiltersType]
                renderFilters(_.reject(currentFilters, "selected"))

        toggleFilterSelection = (type, id) ->
            currentFiltersType = getFiltersType()

            filters = $scope.filters[type]
            filter = _.find(filters, {id: id})
            filter.selected = (not filter.selected)

            if filter.selected
                selectedFilters.push(filter)
                $scope.$apply ->
                    $ctrl.selectFilter(type, id)
            else
                selectedFilters = _.reject selectedFilters, (selected) ->
                    return filter.type == selected.type &&  filter.id == selected.id

                $ctrl.unselectFilter(type, id)

            renderSelectedFilters(selectedFilters)

            if type == currentFiltersType
                renderFilters(_.reject(filters, "selected"))

            reloadUserstories()

        selectQFilter = debounceLeading 100, (value) ->
            return if value is undefined

            if value.length == 0
                $ctrl.replaceFilter("q", null)
            else
                $ctrl.replaceFilter("q", value)

            reloadUserstories()

        $scope.$watch("filtersQ", selectQFilter)

        ## Angular Watchers
        $scope.$on "backlog:loaded", (ctx) ->
            initializeSelectedFilters()

        $scope.$on "filters:update", (ctx) ->
            $ctrl.generateFilters().then () ->
                filters = $scope.filters[currentFiltersType]

                if currentFiltersType
                    renderFilters(_.reject(filters, "selected"))

        ## Dom Event Handlers
        $el.on "click", ".filters-cats > ul > li > a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            tags = $scope.filters[target.data("type")]

            renderFilters(_.reject(tags, "selected"))
            showFilters(target.attr("title"), target.data('type'))

        $el.on "click", ".filters-inner > .filters-step-cat > .breadcrumb > .back", (event) ->
            event.preventDefault()
            showCategories()

        $el.on "click", ".remove-filter", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget).parent()
            id = target.data("id")
            type = target.data("type")
            toggleFilterSelection(type, id)

        $el.on "click", ".filter-list .single-filter", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            if target.hasClass("active")
                target.removeClass("active")
            else
                target.addClass("active")

            id = target.data("id")
            type = target.data("type")
            toggleFilterSelection(type, id)

    return {link:link}

module.directive("tgBacklogFilters", ["$q", "$log", "$tgLocation", "$tgTemplate", "$compile", BacklogFiltersDirective])
