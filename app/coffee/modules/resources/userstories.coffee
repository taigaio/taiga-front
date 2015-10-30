###
# Copyright (C) 2014-2015 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014-2015 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2015 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/resources/userstories.coffee
###

taiga = @.taiga

generateHash = taiga.generateHash

resourceProvider = ($repo, $http, $urls, $storage) ->
    service = {}
    hashSuffix = "userstories-queryparams"

    service.get = (projectId, usId) ->
        params = service.getQueryParams(projectId)
        params.project = projectId
        return $repo.queryOne("userstories", usId, params)

    service.getByRef = (projectId, ref) ->
        params = service.getQueryParams(projectId)
        params.project = projectId
        params.ref = ref
        return $repo.queryOne("userstories", "by_ref", params)

    service.listInAllProjects = (filters) ->
        return $repo.queryMany("userstories", filters)

    service.filtersData = (params) ->
        return $repo.queryOneRaw("userstories-filters", null, params)

    service.listUnassigned = (projectId, filters) ->
        params = {"project": projectId, "milestone": "null"}
        params = _.extend({}, params, filters or {})
        service.storeQueryParams(projectId, params)
        return $repo.queryMany("userstories", params)

    service.listAll = (projectId, filters) ->
        params = {"project": projectId}
        params = _.extend({}, params, filters or {})
        service.storeQueryParams(projectId, params)
        return $repo.queryMany("userstories", params)

    service.bulkCreate = (projectId, status, bulk) ->
        data = {
            project_id: projectId
            status_id: status
            bulk_stories: bulk
        }

        url = $urls.resolve("bulk-create-us")

        return $http.post(url, data)

    service.upvote = (userStoryId) ->
        url = $urls.resolve("userstory-upvote", userStoryId)
        return $http.post(url)

    service.downvote = (userStoryId) ->
        url = $urls.resolve("userstory-downvote", userStoryId)
        return $http.post(url)

    service.watch = (userStoryId) ->
        url = $urls.resolve("userstory-watch", userStoryId)
        return $http.post(url)

    service.unwatch = (userStoryId) ->
        url = $urls.resolve("userstory-unwatch", userStoryId)
        return $http.post(url)

    service.bulkUpdateBacklogOrder = (projectId, data) ->
        url = $urls.resolve("bulk-update-us-backlog-order")
        params = {project_id: projectId, bulk_stories: data}
        return $http.post(url, params)

    service.bulkUpdateSprintOrder = (projectId, data) ->
        url = $urls.resolve("bulk-update-us-sprint-order")
        params = {project_id: projectId, bulk_stories: data}
        return $http.post(url, params)

    service.bulkUpdateKanbanOrder = (projectId, data) ->
        url = $urls.resolve("bulk-update-us-kanban-order")
        params = {project_id: projectId, bulk_stories: data}
        return $http.post(url, params)

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

    service.storeShowTags = (projectId, showTags) ->
        hash = generateHash([projectId, 'showTags'])
        $storage.set(hash, showTags)

    service.getShowTags = (projectId) ->
        hash = generateHash([projectId, 'showTags'])
        return $storage.get(hash) or null

    return (instance) ->
        instance.userstories = service

module = angular.module("taigaResources")
module.factory("$tgUserstoriesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", "$tgStorage", resourceProvider])
