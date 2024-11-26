###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
