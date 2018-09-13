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
# File: modules/resources/users.coffee
###


taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($http, $urls) ->
    service = {}

    service.contacts = (userId, options={}) ->
        url = $urls.resolve("user-contacts", userId)
        httpOptions = {headers: {}}

        if not options.enablePagination
            httpOptions.headers["x-disable-pagination"] =  "1"

        return $http.get(url, {}, httpOptions)
            .then (result) ->
                return result.data

    return (instance) ->
        instance.users = service


module = angular.module("taigaResources")
module.factory("$tgUsersResourcesProvider", ["$tgHttp", "$tgUrls", "$q",
                                                    resourceProvider])
