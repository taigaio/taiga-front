###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

generateHash = taiga.generateHash

class FilterRemoteStorageService extends taiga.Service
    @.$inject = [
        "$q",
        "$tgUrls",
        "$tgHttp"
    ]

    constructor: (@q, @urls, @http) ->

    storeFilters: (projectId, myFilters, filtersHashSuffix) ->
        deferred = @q.defer()
        url = @urls.resolve("user-storage")
        ns = "#{projectId}:#{filtersHashSuffix}"
        hash = generateHash([projectId, ns])
        if _.isEmpty(myFilters)
            promise = @http.delete("#{url}/#{hash}", {key: hash, value:myFilters})
            promise.then ->
                deferred.resolve()
            promise.then null, ->
                deferred.reject()
        else
            promise = @http.put("#{url}/#{hash}", {key: hash, value:myFilters})
            promise.then (data) ->
                deferred.resolve()
            promise.then null, (data) =>
                innerPromise = @http.post("#{url}", {key: hash, value:myFilters})
                innerPromise.then ->
                    deferred.resolve()
                innerPromise.then null, ->
                    deferred.reject()
        return deferred.promise

    getFilters: (projectId, filtersHashSuffix) ->
        deferred = @q.defer()
        url = @urls.resolve("user-storage")
        ns = "#{projectId}:#{filtersHashSuffix}"
        hash = generateHash([projectId, ns])

        promise = @http.get("#{url}/#{hash}")
        promise.then (data) ->
            deferred.resolve(data.data.value)
        promise.then null, (data) ->
            deferred.resolve({})

        return deferred.promise

angular.module("taigaComponents").service("tgFilterRemoteStorageService", FilterRemoteStorageService)
