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
# File: components/filter/filter-remote.service.coffee
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
