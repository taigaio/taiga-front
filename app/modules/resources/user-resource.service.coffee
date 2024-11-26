###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

Resource = (urlsService, http, paginateResponseService) ->
    service = {}

    service.getUserStorage = (key) ->
        url = urlsService.resolve("user-storage")

        if key
            url += '/' + key

        httpOptions = {}

        return http.get(url, {}).then (response) ->
            return response.data.value

    service.setUserStorage = (key, value) ->
        url = urlsService.resolve("user-storage") + '/' + key

        params = {
            key: key,
            value: value
        }

        return http.put(url, params)

    service.createUserStorage = (key, value) ->
        url = urlsService.resolve("user-storage")

        params = {
            key: key,
            value: value
        }

        return http.post(url, params)

    return () ->
        return {"user": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgUserResources", Resource)
