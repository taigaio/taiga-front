###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

resourceProvider = ($repo, $urls, $http, $q) ->
    service = {}

    service.do = (projectId, term) ->
        deferredAbort = $q.defer()

        url = $urls.resolve("search")
        params = {
            url: url,
            method: "GET",
            timeout: deferredAbort.promise,
            cancelable: true,
            params: {
                project: projectId
                text: term,
                get_all: false,
            }
        }

        request = $http.request(params).then (data) ->
            return data.data

        request.abort = () ->
            deferredAbort.resolve()

        request.finally = () ->
            request.abort = angular.noop
            deferredAbort = request = null

        return request

    return (instance) ->
        instance.search = service

module = angular.module("taigaResources")
module.factory("$tgSearchResourcesProvider", ["$tgRepo", "$tgUrls", "$tgHttp", "$q", resourceProvider])
