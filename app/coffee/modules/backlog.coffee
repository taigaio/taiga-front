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

class BacklogController extends taiga.TaigaController
    constructor: (@scope, @repo, @confirm, @rs, @params, @q) ->
        promise = @.loadInitialData()
        promise.then null, =>
            console.log "FAIL"

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

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            console.log "resolve", data.project
            @scope.projectId = data.project
            return @rs.projects.get(@scope.projectId)

        # Load project
        promise = promise.then (project) =>
            @scope.project = project
            return @.loadBacklog()

        return promise

    ## Template actions

    deleteUserStory: (us) ->
        title = "Delete User Story"
        subtitle = us.subject

        @confirm.ask(title, subtitle).then =>
            console.log "#TODO"

    addNewUs: (type) ->
        switch type
            when "standard" then @rootscope.$emit("usform:new")
            when "bulk" then @rootscope.$emit("usform:bulk")


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


module = angular.module("taigaBacklog", [])
module.directive("tgBacklog", ["$compile", "$templateCache", BacklogDirective])
module.directive("tgSprint", ["$compile", SprintDirective])
module.controller("BacklogController", [
    "$scope",
    "$tgRepo",
    "$tgConfirm",
    "$tgResources",
    "$routeParams",
    "$q",
    BacklogController
])
