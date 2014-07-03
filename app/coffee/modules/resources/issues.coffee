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
# File: modules/resources/issues.coffee
###


taiga = @.taiga

resourceProvider = ($repo) ->
    service = {}

    service.get = (projectId, issueId) ->
        return $repo.queryOne("issues", issueId)

    service.list = (projectId, filters) ->
        params = {project: projectId}
        params = _.extend({}, params, filters or {})
        return $repo.queryPaginated("issues", params)

    service.stats = (projectId) ->
        return $repo.queryOneRaw("projects", "#{projectId}/issues_stats")

    service.filtersData = (projectId) ->
        return $repo.queryOneRaw("projects", "#{projectId}/issue_filters_data")

    return (instance) ->
        instance.issues = service


module = angular.module("taigaResources")
module.factory("$tgIssuesResourcesProvider", ["$tgRepo", resourceProvider])
