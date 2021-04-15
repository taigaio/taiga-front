###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

Resource = (urlsService, http) ->
    service = {}

    service.listInAllProjects = (params) ->
        url = urlsService.resolve("tasks")
        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    return () ->
        return {"tasks": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgTasksResource", Resource)
