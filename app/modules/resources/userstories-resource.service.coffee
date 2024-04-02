###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

Resource = (urlsService, http) ->
    service = {}

    service.listInAllProjects = (params, pagination=false) ->
        url = urlsService.resolve("userstories")

        if !pagination
            httpOptions = {
                headers: {
                    "x-disable-pagination": "1"
                }
            }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.listAllInProject = (projectId) ->
        url = urlsService.resolve("userstories")

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        params = {
            project: projectId
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.listInEpic = (epicIid) ->
        url = urlsService.resolve("userstories")

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        params = {
            epic: epicIid,
            order_by: 'epic_order',
            include_tasks: true
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    return () ->
        return {"userstories": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgUserstoriesResource", Resource)
