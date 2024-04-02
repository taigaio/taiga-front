###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

Resource = (urlsService, http) ->
    service = {}

    service.listInAllProjects = (params) ->
        url = urlsService.resolve("epics")

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.list = (projectId, page=0) ->
        url = urlsService.resolve("epics")

        params = {project: projectId, page: page}

        return http.get(url, params)
            .then (result) ->
                return {
                    list: Immutable.fromJS(result.data)
                    headers: result.headers
                }

    service.patch = (id, patch) ->
        url = urlsService.resolve("epics") + "/#{id}"

        return http.patch(url, patch)
            .then (result) -> Immutable.fromJS(result.data)

    service.post = (params) ->
        url = urlsService.resolve("epics")

        return http.post(url, params)
            .then (result) -> Immutable.fromJS(result.data)

    service.reorder = (id, data, setOrders) ->
        url = urlsService.resolve("epics") + "/#{id}"

        options = {"headers": {"set-orders": JSON.stringify(setOrders)}}

        return http.patch(url, data, null, options)
            .then (result) -> Immutable.fromJS(result.data)

    service.addRelatedUserstory = (epicId, userstoryId) ->
        url = urlsService.resolve("epic-related-userstories", epicId)

        params = {
            user_story: userstoryId
            epic: epicId
        }

        return http.post(url, params)

    service.reorderRelatedUserstory = (epicId, userstoryId, data, setOrders) ->
        url = urlsService.resolve("epic-related-userstories", epicId) + "/#{userstoryId}"

        options = {"headers": {"set-orders": JSON.stringify(setOrders)}}

        return http.patch(url, data, null, options)

    service.bulkCreateRelatedUserStories = (epicId, projectId, bulk_userstories) ->
        url = urlsService.resolve("epic-related-userstories-bulk-create", epicId)

        params = {
            bulk_userstories: bulk_userstories,
            project_id: projectId
        }

        return http.post(url, params)

    service.deleteRelatedUserstory = (epicId, userstoryId) ->
        url = urlsService.resolve("epic-related-userstories", epicId) + "/#{userstoryId}"

        return http.delete(url)

    return () ->
        return {"epics": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgEpicsResource", Resource)
