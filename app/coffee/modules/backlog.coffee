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

taiga = @.taiga

class BacklogController extends taiga.TaigaController
    constructor: (@scope, @repo, @params, @rs) ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            console.log "resolve", data.project
            @scope.projectId = data.project
            return @rs.getProject(@scope.projectId)

        # Load project
        promise = promise.then (project) =>
            @scope.project = project
            console.log project
            return @rs.getMilestones(@scope.projectId)

        # Load milestones
        promise = promise.then (milestones) =>
            @scope.milestones = milestones
            return @rs.getBacklog(@scope.projectId)

        # Load unassigned userstories
        promise = promise.then (userstories) =>
            @scope.userstories = userstories

        # Obviously fail condition
        promise.then null, =>
            console.log "FAIL"


BacklogDirective = ($compile) ->
    controller: ["$scope", "$tgRepo", "$routeParams", "$tgResources", BacklogController]
    link: (scope, element, attrs, ctrl) ->


BacklogTableDirective = ($compile, $templateCache) ->
    require: "^tgBacklog"
    link: (scope, element, attrs, ctrl) ->
        content = $templateCache.get("backlog-row.html")
        scope.$watch "userstories", (userstories) =>
            console.log "ready to render", userstories


module = angular.module("taigaBacklog", [])
module.directive("tgBacklog", ["$compile", BacklogDirective])
module.directive("tgBacklogTable", ["$compile", "$templateCache", BacklogTableDirective])
