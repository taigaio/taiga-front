###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: modules/resources/sprints.coffee
###

taiga = @.taiga

generateHash = taiga.generateHash

resourceProvider = ($repo, $model, $storage) ->
    service = {}

    service.get = (projectId, sprintId) ->
        return $repo.queryOne("milestones", sprintId).then (sprint) ->
            uses = sprint.user_stories
            uses = _.map(uses, (u) -> $model.make_model("userstories", u))
            sprint._attrs.user_stories = uses
            return sprint

    service.stats = (projectId, sprintId) ->
        return $repo.queryOneRaw("milestones", "#{sprintId}/stats")

    service.list = (projectId, filters) ->
        params = {"project": projectId}
        params = _.extend({}, params, filters or {})
        return $repo.queryMany("milestones", params, {}, true).then (result) =>
            milestones = result[0]
            headers = result[1]

            for m in milestones
                uses = m.user_stories
                uses = _.map(uses, (u) => $model.make_model("userstories", u))
                m._attrs.user_stories = uses

            return {
                milestones: milestones,
                closed: parseInt(headers("Taiga-Info-Total-Closed-Milestones"), 10),
                open: parseInt(headers("Taiga-Info-Total-Opened-Milestones"), 10)
            }


    return (instance) ->
        instance.sprints = service

module = angular.module("taigaResources")
module.factory("$tgSprintsResourcesProvider", ["$tgRepo", "$tgModel", "$tgStorage", resourceProvider])
