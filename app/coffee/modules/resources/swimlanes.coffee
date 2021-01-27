###
# Copyright (C) 2014-present Taiga Agile LLC
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
# File: modules/resources/swimlanes.coffee
###


taiga = @.taiga

generateHash = taiga.generateHash

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.list = (projectId) ->
        params = {project: projectId}
        return $repo.queryMany("swimlanes", params)

    service.create = (projectId, name, order) ->
        url = $urls.resolve("swimlanes")
        params = {
            project: projectId,
            name: name,
        }
        if (order)
            params.order = order

        return $http.post(url, params)

    service.edit = (swimlaneId, name) ->
        url = $urls.resolve("swimlanes")
        url = "#{url}/#{swimlaneId}"
        params = {
            name
        }
        return $http.patch(url, params)

    service.bulkUpdateOrder = (project, swimlanesOrder) ->
        url = $urls.resolve("swimlanes")
        url = "#{url}/bulk_update_order"
        params = {
            project,
            bulk_swimlanes: swimlanesOrder
        }
        return $http.post(url, params)

    service.wipLimitUpdate = (swimlaneId, wip_limit) ->
        url = $urls.resolve("swimlane-userstory-statuses")
        url = "#{url}/#{swimlaneId}"
        params = {
            wip_limit
        }
        return $http.patch(url, params)

    service.delete = (swimlaneId, moveTo) ->
        url = $urls.resolve("swimlanes")
        if (moveTo)
            url = "#{url}/#{swimlaneId}?moveTo=#{moveTo}"
        else
            url = "#{url}/#{swimlaneId}"
        return $http.delete(url)

    return (instance) ->
        instance.swimlanes = service


module = angular.module("taigaResources")
module.factory("$tgSwimlanesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
