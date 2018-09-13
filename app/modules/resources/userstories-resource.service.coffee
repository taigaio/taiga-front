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
# File: resources/userstories-resource.service.coffee
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
