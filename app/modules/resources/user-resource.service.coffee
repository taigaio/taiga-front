###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
