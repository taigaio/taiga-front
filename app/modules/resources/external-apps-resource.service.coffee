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
# File: resources/external-apps-resource.service.coffee
###

Resource = (urlsService, http) ->
    service = {}

    service.getApplicationToken = (applicationId, state) ->
        url = urlsService.resolve("applications")
        url = "#{url}/#{applicationId}/token?state=#{state}"
        return http.get(url).then (result) ->
            Immutable.fromJS(result.data)

    service.authorizeApplicationToken = (applicationId, state) ->
        url = urlsService.resolve("application-tokens")
        url = "#{url}/authorize"
        data = {
            "state": state
            "application": applicationId
        }

        return http.post(url, data).then (result) ->
            Immutable.fromJS(result.data)

    return () ->
        return {"externalapps": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgExternalAppsResource", Resource)
