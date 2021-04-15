###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

Resource = (urlsService, http) ->
    service = {}

    service.discover = (applicationId, state) ->
        url = urlsService.resolve("stats-discover")
        return http.get(url).then (result) ->
            Immutable.fromJS(result.data)

    return () ->
        return {"stats": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgStatsResource", Resource)
