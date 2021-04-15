###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
