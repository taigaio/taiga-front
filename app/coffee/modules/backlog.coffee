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
    constructor: (@repo) ->
        console.log "foo"

    getMilestones: ->
        projectId = 1
        return @repo.queryMany("milestones", {project:projectId}).then (milestones) ->
            console.log milestones
            return milestones


BacklogDirective = ($compile) ->
    controller: ["$tgRepo", BacklogController]
    link: (scope, element, attrs, ctrl) ->
        ctrl.getMilestones().then =>
            console.log "kaka"


BacklogTableDirective = ($compile, $templateCache) ->
    require: "^tgBacklog"
    link: (scope, element, attrs, ctrl) ->
        content = $templateCache.get("backlog-row.html")


module = angular.module("taiga")
module.directive("tgBacklog", ["$compile", BacklogDirective])
module.directive("tgBacklogTable", ["$compile", "$templateCache", BacklogTableDirective])
