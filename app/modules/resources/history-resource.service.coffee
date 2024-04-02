###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

Resource = (urlsService, http) ->
    service = {}

    service.getHistory = (historyType, contentType, objectId, page) ->
        url = urlsService.resolve("history/#{contentType}", )
        return http.get("#{url}/#{objectId}", {page: page, type: historyType})
            .then (result) ->
                return {
                    list: Immutable.fromJS(result.data)
                    headers: result.headers
                }

    return () ->
        return {"history": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgHistory", Resource)
