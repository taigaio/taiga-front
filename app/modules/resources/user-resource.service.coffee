###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: resources/user-resource.service.coffee
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
