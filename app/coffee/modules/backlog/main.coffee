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

class BacklogController extends mixOf(taiga.Controller, taiga.PageMixin)
    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q) ->
        _.bindAll(@)
        promise = @.loadInitialData()
        promise.then null, =>
            console.log "FAIL"

        @rootscope.$on("usform:bulk:success", @.loadUserstories)

    initializeProjectStats: ->
        @scope.stats = {
            total_points: "--"
            defined_points: "--"
            assigned_points: "--"
            closed_points: "--"
            completedPercentage: "--%"
        }

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @scope.stats = stats
            completedPercentage = Math.round(100 * stats.closed_points / stats.total_points)
            @scope.stats.completedPercentage = "#{completedPercentage}%"
            return stats

    loadSprints: ->
        return @rs.sprints.list(@scope.projectId).then (sprints) =>
            @scope.sprints = sprints
            return sprints

    loadUserstories: ->
        return @rs.userstories.listUnassigned(@scope.projectId).then (userstories) =>
            @scope.userstories = userstories
            @scope.filters = @.generateFilters()

            @.filterVisibleUserstories()
            return userstories

    loadBacklog: ->
        return @q.all([
            @.loadProjectStats(),
            @.loadSprints(),
            @.loadUserstories()
        ])

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.points = _.sortBy(project.points, "order")
            @scope.statusList = _.sortBy(project.us_statuses, "id")
            return project

    loadInitialData: ->
        # Set stats initial values
        @.initializeProjectStats()

        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadBacklog())

    filterVisibleUserstories: ->
        selectedTags = _.filter(@scope.filters.tags, "selected")
        selectedTags = _.map(selectedTags, "name")

        @scope.visibleUserstories = []

        if selectedTags.length == 0
            @scope.visibleUserstories = _.clone(@scope.userstories, false)
        else
            @scope.visibleUserstories = _.reject @scope.userstories, (us) =>
                if _.intersection(selectedTags, us.tags).length == 0
                    return true
                else
                    return false

    generateFilters: ->
        filters = {}
        plainTags = _.flatten(_.map(@scope.userstories, "tags"))
        filters.tags = _.map(_.countBy(plainTags), (v, k) -> {name: k, count:v})
        return filters

    ## Template actions

    editUserStory: (us) ->
        @rootscope.$broadcast("usform:edit", us)

    deleteUserStory: (us) ->
        title = "Delete User Story"
        subtitle = us.subject

        @confirm.ask(title, subtitle).then =>
            @.repo.remove(us).then =>
                @.loadBacklog()

    addNewUs: (type) ->
        switch type
            when "standard" then @rootscope.$broadcast("usform:new")
            when "bulk" then @rootscope.$broadcast("usform:bulk")


#############################################################################
## Backlog Directive
#############################################################################

BacklogDirective = ($repo) ->
    #########################
    ## Drag & Drop Link
    #########################

    linkSortable = ($scope, $el, $attrs, $ctrl) ->
        resortAndSave = ->
            toSave = []
            for item, i in $scope.userstories
                if item.order == i
                    continue
                item.order = i

            toSave = _.filter($scope.userstories, (x) -> x.isModified())
            $repo.saveAll(toSave).then ->
                console.log "FINISHED", arguments

        onUpdateItem = (event) ->
            console.log "onUpdate", event

            item = angular.element(event.item)
            itemScope = item.scope()

            ids = _.map($scope.userstories, "id")
            index = ids.indexOf(itemScope.us.id)

            $scope.userstories.splice(index, 1)
            $scope.userstories.splice(item.index(), 0, itemScope.us)

            resortAndSave()

        onAddItem = (event) ->
            item = angular.element(event.item)
            itemScope = item.scope()
            itemIndex = item.index()

            itemScope.us.milestone = null
            userstories = $scope.userstories
            userstories.splice(itemIndex, 0, itemScope.us)

            item.remove()
            item.off()

            $scope.$apply()
            resortAndSave()

        onRemoveItem = (event) ->
            item = angular.element(event.item)
            itemScope = item.scope()

            ids = _.map($scope.userstories, "id")
            index = ids.indexOf(itemScope.us.id)

            if index != -1
                userstories = $scope.userstories
                userstories.splice(index, 1)

            item.off()
            itemScope.$destroy()

        dom = $el.find(".backlog-table-body")
        sortable = new Sortable(dom[0], {
            group: "backlog",
            selector: ".us-item-row",
            onUpdate: onUpdateItem
            onAdd: onAddItem
            onRemove: onRemoveItem
        })

    ##############################
    ## Move to current sprint link
    ##############################
    linkMoveToCurrentSprint = ($scope, $el, $attrs, $ctrl) ->

        moveToCurrentSprint = (selectedUss) ->
            ussCurrent = _($scope.userstories)
            # Remove them from backlog
            $scope.userstories = ussCurrent.without.apply(ussCurrent, selectedUss).value()
            # Add them to current sprint
            $scope.sprints[0].user_stories = _.union(selectedUss, $scope.sprints[0].user_stories)
            $ctrl.filterVisibleUserstories()
            $repo.saveAll(selectedUss)


        # Enable move to current sprint only when there are selected us's
        $el.on "change", ".backlog-table-body .user-stories input:checkbox", (event) ->
            moveToCurrentSprintDom = $el.find("#move-to-current-sprint")
            if $el.find(".backlog-table-body .user-stories input:checkbox:checked").length > 0 and $scope.sprints.length > 0
                moveToCurrentSprintDom.show()
            else
                moveToCurrentSprintDom.hide()

        $el.on "click", "#move-to-current-sprint", (event) =>
            # Calculating the us's to be modified
            ussDom = $el.find(".backlog-table-body .user-stories input:checkbox:checked")
            ussToMove = _.map ussDom, (item) ->
                itemScope = angular.element(item).scope()
                itemScope.us.milestone = $scope.sprints[0].id
                return itemScope.us

            $scope.$apply(_.partial(moveToCurrentSprint, ussToMove))

    #########################
    ## Filters Link
    #########################

    linkFilters = ($scope, $el, $attrs, $ctrl) ->
        $scope.filtersSearch = {}
        $el.on "click", "#show-filters-button", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            $el.find("sidebar.filters-bar").toggle()
            target.toggleClass("active")
            toggleText(target.find(".text"), ["Hide Filters", "Show Filters"]) # TODO: i18n

        $el.on "click", "section.filters a.single-filter", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            targetScope = target.scope()

            $scope.$apply ->
                targetScope.tag.selected = not (targetScope.tag.selected or false)
                $ctrl.filterVisibleUserstories()

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSortable($scope, $el, $attrs, $ctrl)
        linkMoveToCurrentSprint($scope, $el, $attrs, $ctrl)
        linkFilters($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

#############################################################################
## Sprint Directive
#############################################################################

BacklogSprintDirective = ($repo) ->

    #########################
    ## Common parts
    #########################

    linkCommon = ($scope, $el, $attrs, $ctrl) ->
        sprint = $scope.$eval($attrs.tgBacklogSprint)
        if $scope.$first
            $el.addClass("sprint-current")

        if sprint.closed
            $el.addClass("sprint-closed")

        if not $scope.$first and not sprint.closed
            $el.addClass("sprint-old-open")

        # Update progress bars
        progressPercentage = Math.round(100 * (sprint.closed_points / sprint.total_points))
        $el.find(".current-progress").css("width", "#{progressPercentage}%")

        # Event Handlers
        $el.on "click", ".sprint-summary > a", (event) ->
            $el.find(".sprint-table").toggle()

    #########################
    ## Drag & Drop Link
    #########################

    linkSortable = ($scope, $el, $attrs, $ctrl) ->
        resortAndSave = ->
            toSave = []
            for item, i in $scope.sprint.user_stories
                if item.order == i
                    continue
                item.order = i

            toSave = _.filter($scope.sprint.user_stories, (x) -> x.isModified())
            $repo.saveAll(toSave).then ->
                console.log "FINISHED", arguments

        onUpdateItem = (event) ->
            item = angular.element(event.item)
            itemScope = item.scope()

            ids = _.map($scope.sprint.user_stories, {"id": itemScope.us.id})
            index = ids.indexOf(itemScope.us.id)

            $scope.sprint.user_stories.splice(index, 1)
            $scope.sprint.user_stories.splice(item.index(), 0, itemScope.us)
            resortAndSave()

        onAddItem = (event) ->
            item = angular.element(event.item)
            itemScope = item.scope()
            itemIndex = item.index()

            itemScope.us.milestone = $scope.sprint.id
            userstories = $scope.sprint.user_stories
            userstories.splice(itemIndex, 0, itemScope.us)

            item.remove()
            item.off()

            $scope.$apply()
            resortAndSave()

        onRemoveItem = (event) ->
            item = angular.element(event.item)
            itemScope = item.scope()

            ids = _.map($scope.sprint.user_stories, "id")
            index = ids.indexOf(itemScope.us.id)

            if index != -1
                userstories = $scope.sprint.user_stories
                userstories.splice(index, 1)

            item.off()
            itemScope.$destroy()

        dom = $el.find(".sprint-table")
        sortable = new Sortable(dom[0], {
            group: "backlog",
            selector: ".milestone-us-item-row",
            onUpdate: onUpdateItem,
            onAdd: onAddItem,
            onRemove: onRemoveItem,
        })

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.closest("div.wrapper").controller()
        linkSortable($scope, $el, $attrs, $ctrl)
        linkCommon($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


BacklogSummaryDirective = ->
    link = ($scope, $el, $attrs) ->
    return {link:link}

module = angular.module("taigaBacklog")
module.directive("tgBacklog", ["$tgRepo", BacklogDirective])
module.directive("tgBacklogSprint", ["$tgRepo", BacklogSprintDirective])
module.directive("tgBacklogSummary", BacklogSummaryDirective)

module.controller("BacklogController", [
    "$scope",
    "$rootScope",
    "$tgRepo",
    "$tgConfirm",
    "$tgResources",
    "$routeParams",
    "$q",
    BacklogController
])
