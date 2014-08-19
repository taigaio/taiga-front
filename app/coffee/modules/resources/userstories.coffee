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

    service.listUnassigned = (projectId, filters) ->
        params = {"project": projectId, "milestone": "null"}
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

    service.bulkUpdateOrder = (projectId, data) ->
        url = $urls.resolve("bulk-update-us-order")
        params = {project_id: projectId, bulk_stories: data}
        return $http.post(url, params)

    service.history = (usId) ->
        return $repo.queryOneRaw("history/userstory", usId)

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
        instance.userstories = service

module = angular.module("taigaResources")
module.factory("$tgUserstoriesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", "$tgStorage", resourceProvider])
