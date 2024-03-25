###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
