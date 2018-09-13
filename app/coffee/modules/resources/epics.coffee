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
# File: modules/resources/epics.coffee
###


taiga = @.taiga

generateHash = taiga.generateHash


resourceProvider = ($repo, $http, $urls, $storage) ->
    service = {}
    hashSuffix = "epics-queryparams"

    service.getByRef = (projectId, ref) ->
        params = service.getQueryParams(projectId)
        params.project = projectId
        params.ref = ref
        return $repo.queryOne("epics", "by_ref", params)

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

    service.upvote = (epicId) ->
        url = $urls.resolve("epic-upvote", epicId)
        return $http.post(url)

    service.downvote = (epicId) ->
        url = $urls.resolve("epic-downvote", epicId)
        return $http.post(url)

    service.watch = (epicId) ->
        url = $urls.resolve("epic-watch", epicId)
        return $http.post(url)

    service.unwatch = (epicId) ->
        url = $urls.resolve("epic-unwatch", epicId)
        return $http.post(url)

    return (instance) ->
        instance.epics = service


module = angular.module("taigaResources")
module.factory("$tgEpicsResourcesProvider", ["$tgRepo","$tgHttp", "$tgUrls", "$tgStorage", resourceProvider])
