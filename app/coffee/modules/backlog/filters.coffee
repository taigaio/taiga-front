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
# File: modules/backlog/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy
debounce = @.taiga.debounce


module = angular.module("taigaBacklog")

#############################################################################
## Issues Filters Directive
#############################################################################

BacklogFiltersDirective = ($log, $location) ->
    template = _.template("""
    <% _.each(filters, function(f) { %>
        <% if (f.selected) { %>
        <a class="single-filter active"
            data-type="<%= f.type %>"
            data-id="<%= f.id %>">
            <span class="name"><%- f.name %></span>
            <span class="number"><%- f.count %></span>
        </a>
        <% } else { %>
        <a class="single-filter"
            data-type="<%= f.type %>"
            data-id="<%= f.id %>">
            <span class="name"><%- f.name %></span>
            <span class="number"><%- f.count %></span>
        </a>
        <% } %>
    <% }) %>
    """)

    templateSelected = _.template("""
    <% _.each(filters, function(f) { %>
    <a class="single-filter selected"
       data-type="<%= f.type %>"
       data-id="<%= f.id %>">
        <span class="name"><%- f.name %></span>
        <span class="icon icon-delete"></span>
    </a>
    <% }) %>
    """)


    link = ($scope, $el, $attrs) ->
        $ctrl = $el.closest(".wrapper").controller()
        selectedFilters = []

        showFilters = (title) ->
            $el.find(".filters-cats").hide()
            $el.find(".filter-list").show()
            $el.find("h1 a.subfilter").removeClass("hidden")
            $el.find("h1 a.subfilter span.title").html(title)

        showCategories = ->
            $el.find(".filters-cats").show()
            $el.find(".filter-list").hide()
            $el.find("h1 a.subfilter").addClass("hidden")

        initializeSelectedFilters = (filters) ->
            for name, values of filters
                for val in values
                    selectedFilters.push(val) if val.selected

            renderSelectedFilters()

        renderSelectedFilters = ->
            html = templateSelected({filters:selectedFilters})
            $el.find(".filters-applied").html(html)

        renderFilters = (filters) ->
            html = template({filters:filters})
            $el.find(".filter-list").html(html)

        toggleFilterSelection = (type, id) ->
            filters = $scope.filters[type]
            filter = _.find(filters, {id: taiga.toString(id)})
            filter.selected = (not filter.selected)
            if filter.selected
                selectedFilters.push(filter)
                $scope.$apply ->
                    $ctrl.selectFilter(type, id)
                    $ctrl.filterVisibleUserstories()
            else
                selectedFilters = _.reject(selectedFilters, filter)
                $scope.$apply ->
                    $ctrl.unselectFilter(type, id)
                    $ctrl.filterVisibleUserstories()

            renderSelectedFilters(selectedFilters)
            renderFilters(_.reject(filters, "selected"))

        selectSubjectFilter = debounce 400, (value) ->
            return if value is undefined
            if value.length == 0
                $ctrl.replaceFilter("subject", null)
            else
                $ctrl.replaceFilter("subject", value)
            $ctrl.loadUserstories()

        $scope.$watch("filtersSubject", selectSubjectFilter)

        # Angular Watchers
        $scope.$on "filters:loaded", (ctx, filters) ->
            initializeSelectedFilters(filters)

        # Dom Event Handlers
        $el.on "click", ".filters-cats > ul > li > a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            tags = $scope.filters[target.data("type")]

            renderFilters(_.reject(tags, "selected"))
            showFilters(target.attr("title"))

        $el.on "click", ".filters-inner > h1 > a.title", (event) ->
            event.preventDefault()
            showCategories($el)

        $el.on "click", ".filters-applied a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            id = target.data("id")
            type = target.data("type")
            toggleFilterSelection(type, id)

        $el.on "click", ".filter-list .single-filter", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            if target.hasClass("active")
                target.removeClass("active")
                # target.css("background-color")
            else
                target.addClass("active")

            id = target.data("id")
            type = target.data("type")
            toggleFilterSelection(type, id)

    return {link:link}

module.directive("tgBacklogFilters", ["$log", "$tgLocation", BacklogFiltersDirective])
