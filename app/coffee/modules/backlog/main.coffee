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


BacklogDirective = ->
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
    return {link: link}

BacklogSummaryDirective = ->
    link = ($scope, $el, $attrs) ->
    return {link:link}

BacklogSprintDirective = ->
    link = (scope, element, attrs) ->
        sprint = scope.$eval(attrs.tgBacklogSprint)
        if scope.$first
            element.addClass("sprint-current")

        if sprint.closed
            element.addClass("sprint-closed")

        # Event Handlers
        element.on "click", ".sprint-summary > a", (event) ->
            element.find(".sprint-table").toggle()

    return {link: link}


module = angular.module("taigaBacklog")
module.directive("tgBacklog", BacklogDirective)
module.directive("tgBacklogSprint", BacklogSprintDirective)
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
