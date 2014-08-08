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

generateHash = taiga.generateHash

resourceProvider = ($repo, $http, $urls, $storage) ->
    service = {}
    hashSuffix = "issues-queryparams"

    service.get = (projectId, issueId) ->
        params = service.getQueryParams(projectId)
        params.project = projectId
        return $repo.queryOne("issues", issueId, params)

    service.list = (projectId, filters) ->
        params = {project: projectId}
        params = _.extend({}, params, filters or {})
        service.storeQueryParams(projectId, params)
        return $repo.queryPaginated("issues", params)

    service.bulkCreate = (projectId, data) ->
        url = $urls.resolve("bulk-create-issues")
        params = {project_id: projectId, bulk_issues: data}
        return $http.post(url, params)

    service.stats = (projectId) ->
        return $repo.queryOneRaw("projects", "#{projectId}/issues_stats")

    service.filtersData = (projectId) ->
        return $repo.queryOneRaw("projects", "#{projectId}/issue_filters_data")

    service.history = (issueId) ->
        return $repo.queryOneRaw("history/issue", issueId)

    service.listValues = (projectId, type) ->
        params = {"project": projectId}
        service.storeQueryParams(projectId, params)
        return $repo.queryMany(type, params)

    service.storeQueryParams = (projectId, params) ->
        ns = "#{projectId}:#{hashSuffix}"
        hash = generateHash([projectId, ns])
        $storage.set(hash, params)

    service.getQueryParams = (projectId) ->
        ns = "#{projectId}:#{hashSuffix}"
        hash = generateHash([projectId, ns])
        return $storage.get(hash) or {}

    return (instance) ->
        instance.issues = service


module = angular.module("taigaResources")
module.factory("$tgIssuesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", "$tgStorage", resourceProvider])
