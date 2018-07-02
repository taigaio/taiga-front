###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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

resourceProvider = ($repo, $http, $urls, $storage, $q) ->
    service = {}
    hashSuffix = "issues-queryparams"

    service.get = (projectId, issueId) ->
        params = service.getQueryParams(projectId)
        params.project = projectId
        return $repo.queryOne("issues", issueId, params)

    service.getByRef = (projectId, ref) ->
        params = service.getQueryParams(projectId)
        params.project = projectId
        params.ref = ref
        return $repo.queryOne("issues", "by_ref", params)

    service.listInAllProjects = (filters) ->
        return $repo.queryMany("issues", filters)

    service.list = (projectId, filters, options) ->
        params = {project: projectId}
        params = _.extend({}, params, filters or {})
        service.storeQueryParams(projectId, params)
        return $repo.queryPaginated("issues", params, options)

    service.listInProject = (projectId, sprintId=null, params) ->
        params = _.merge(params, {project: projectId})
        params.milestone = sprintId if sprintId
        service.storeQueryParams(projectId, params)
        return $repo.queryMany("issues", params)

    service.bulkCreate = (projectId, data) ->
        url = $urls.resolve("bulk-create-issues")
        params = {project_id: projectId, bulk_issues: data}
        return $http.post(url, params)

    service.upvote = (issueId) ->
        url = $urls.resolve("issue-upvote", issueId)
        return $http.post(url)

    service.downvote = (issueId) ->
        url = $urls.resolve("issue-downvote", issueId)
        return $http.post(url)

    service.watch = (issueId) ->
        url = $urls.resolve("issue-watch", issueId)
        return $http.post(url)

    service.unwatch = (issueId) ->
        url = $urls.resolve("issue-unwatch", issueId)
        return $http.post(url)

    service.stats = (projectId) ->
        return $repo.queryOneRaw("projects", "#{projectId}/issues_stats")

    service.filtersData = (params) ->
        return $repo.queryOneRaw("issues-filters", null, params)

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
module.factory("$tgIssuesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", "$tgStorage", "$q", resourceProvider])
