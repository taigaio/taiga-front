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

class ResourcesService extends taiga.TaigaService
    @.$inject = ["$q", "$tgRepo", "$tgUrls", "$tgModel"]

    constructor: (@q, @repo, @urls, @model) ->
        super()

    #############################################################################
    # Common
    #############################################################################

    getProject: (projectId) ->
        return @repo.queryOne("projects", projectId)

    #############################################################################
    # Backlog
    #############################################################################

    getMilestones: (projectId) ->
        return @repo.queryMany("milestones", {project:projectId}).then (milestones) =>
            for m in milestones
                uses = m.user_stories
                uses = _.map(uses, (u) => @model.make_model("userstories", u))
                m._attrs.user_stories = uses
            return milestones

    getBacklog: (projectId) ->
        params = {"project": projectId, "milestone": "null"}
        return @repo.queryMany("userstories", params)

module = angular.module("taigaResources")
module.service("$tgResources", ResourcesService)
