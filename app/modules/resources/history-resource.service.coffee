###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
