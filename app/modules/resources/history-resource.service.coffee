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
# File: resources/history-resource.service.coffee
###

Resource = (urlsService, http) ->
    service = {}

    service.getHistory = (historyType, contentType, objectId, page) ->
        url = urlsService.resolve("history/#{contentType}", )
        return http.get("#{url}/#{objectId}", {page: page, type: historyType})
            .then (result) ->
                return {
                    list: Immutable.fromJS(result.data)
                    headers: result.headers
                }

    return () ->
        return {"history": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgHistory", Resource)
