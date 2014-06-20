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

class BacklogController extends mixOf(taiga.Controller, taiga.PageMixin)
    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q) ->
        _.bindAll(@)
        promise = @.loadInitialData()
        promise.then null, =>
            console.log "FAIL"

        @rootscope.$on("usform:bulk:success", @.loadUserstories)

    loadSprints: ->
        return @rs.sprints.list(@scope.projectId).then (sprints) =>
            @scope.sprints = sprints
            return sprints

    loadUserstories: ->
        return @rs.userstories.listUnassigned(@scope.projectId).then (userstories) =>
            @scope.userstories = userstories
            return userstories

    loadBacklog: ->
        return @q.all([
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
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadBacklog())

    ## Template actions

    deleteUserStory: (us) ->
        title = "Delete User Story"
        subtitle = us.subject

        @confirm.ask(title, subtitle).then =>
            console.log "#TODO"

    addNewUs: (type) ->
        switch type
            when "standard" then @rootscope.$broadcast("usform:new")
            when "bulk" then @rootscope.$broadcast("usform:bulk")


BacklogDirective = ($repo) ->
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
            console.log "BacklogDirective:onAdd", event

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
            console.log "BacklogDirective:onRemove:0:", itemScope.us.id, index

            if index != -1
                userstories = $scope.userstories
                userstories.splice(index, 1)

            item.off()
            itemScope.$destroy()
            console.log "BacklogDirective:onRemove:1:", ids
            console.log "BacklogDirective:onRemove:2:", _.map($scope.userstories, "id")

        dom = $el.find(".backlog-table-body")
        sortable = new Sortable(dom[0], {
            group: "Kaka",
            selector: ".us-item-row",
            onUpdate: onUpdateItem
            onAdd: onAddItem
            onRemove: onRemoveItem
        })

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSortable($scope, $el, $attrs, $ctrl)

    return {link: link}


BacklogSprintDirective = ($repo) ->
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.closest("div.wrapper").controller()
        console.log $ctrl

        sprint = $scope.$eval($attrs.tgBacklogSprint)
        if $scope.$first
            $el.addClass("sprint-current")

        # if sprint.closed
        #     $el.addClass("sprint-closed")

        # Event Handlers
        $el.on "click", ".sprint-summary > a", (event) ->
            $el.find(".sprint-table").toggle()

        $scope.$on "$destroy", ->
            $el.off()

        # Drag & Drop

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
            console.log "onUpdate", event

            item = angular.element(event.item)
            itemScope = item.scope()

            ids = _.map($scope.sprint.user_stories, {"id": itemScope.us.id})
            index = ids.indexOf(itemScope.us.id)

            $scope.sprint.user_stories.splice(index, 1)
            $scope.sprint.user_stories.splice(item.index(), 0, itemScope.us)
            resortAndSave()

        onAddItem = (event) ->
            console.log "onAdd", event

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
            console.log "BacklogSprintDirective:onRemove", event

            item = angular.element(event.item)
            itemScope = item.scope()

            ids = _.map($scope.sprint.user_stories, "id")
            index = ids.indexOf(itemScope.us.id)

            console.log "BacklogSprintDirective:onRemove:0:", itemScope.us.id, index

            if index != -1
                userstories = $scope.sprint.user_stories
                userstories.splice(index, 1)

            item.off()
            itemScope.$destroy()
            console.log "BacklogSprintDirective:onRemove:1", ids
            console.log "BacklogSprintDirective:onRemove:2", _.map($scope.sprint.user_stories, "id")

        dom = $el.find(".sprint-table")
        sortable = new Sortable(dom[0], {
            group: "Kaka",
            selector: ".milestone-us-item-row",
            onUpdate: onUpdateItem,
            onAdd: onAddItem,
            onRemove: onRemoveItem,
        })

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
