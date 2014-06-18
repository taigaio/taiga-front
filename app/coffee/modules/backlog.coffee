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
# File: modules/backlog.coffee
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


BacklogDirective = ($compile, $templateCache) ->
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

    return {link: link}


SprintDirective = ($compile, $templateCache) ->
    link = (scope, element, attrs) ->
        sprint = scope.$eval(attrs.tgSprint)
        if scope.$first
            element.addClass("sprint-current")

        if sprint.closed
            element.addClass("sprint-closed")

        # Event Handlers
        element.on "click", ".sprint-summary > a", (event) ->
            element.find(".sprint-table").toggle()

    return {link: link}


###########################################################################################
# Lightboxes
###########################################################################################

CreateEditUserstoryDirective = ($repo, $model) ->
    link = ($scope, $el, attrs) ->
        $scope.us = {"tags": ["kaka", "pedo", "pis"]}
        # TODO: defaults
        $scope.$on "usform:new", ->
            $scope.us = {"subject": "KAKA"}
            $el.removeClass("hidden")

        $scope.$on "usform:change", (ctx, us) ->
            $el.removeClass("hidden")
            $scope.us = us

        $scope.$on "$destroy", ->
            $el.off()

        # Dom Event Handlers
        $el.on "click", ".markdown-preview a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            target.parent().find("a").removeClass("active")
            target.addClass("active")

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            console.log $scope.us

    return {link: link}

CreateBulkUserstroriesDirective = ($repo, $rs, $rootscope) ->
    link = ($scope, $el, attrs) ->
        $scope.form = {data: ""}

        $scope.$on "usform:bulk", ->
            $el.removeClass("hidden")
            $scope.form = {data: ""}

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()

            data = $scope.form.data
            projectId = $scope.projectId

            $rs.userstories.bulkCreate(projectId, data).then (result) ->
                $rootscope.$broadcast("usform:bulk:success", result)
                $el.addClass("hidden")

    return {link: link}


module = angular.module("taigaBacklog", [])
module.directive("tgBacklog", ["$compile", "$templateCache", BacklogDirective])
module.directive("tgSprint", ["$compile", SprintDirective])
module.directive("tgLbCreateEditUserstory", ["$tgRepo", "$tgModel", CreateEditUserstoryDirective])

module.directive("tgLbCreateBulkUserstories", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    CreateBulkUserstroriesDirective
])

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
