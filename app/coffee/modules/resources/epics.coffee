###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
