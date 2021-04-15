###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.get = (id) ->
        return $repo.queryOne("notify-policies", id)

    service.list = (filters) ->
        params = _.extend({}, params, filters or {})
        return $repo.queryMany("notify-policies", params)

    return (instance) ->
        instance.notifyPolicies = service


module = angular.module("taigaResources")
module.factory("$tgNotifyPoliciesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
