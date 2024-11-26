###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
