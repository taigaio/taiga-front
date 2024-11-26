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
        return $repo.queryOne("user-project-settings", id)

    service.list = (filters) ->
        params = _.extend({}, params, filters or {})
        return $repo.queryMany("user-project-settings", params)

    return (instance) ->
        instance.userProjectSettings = service


module = angular.module("taigaResources")
module.factory("$tgUserProjectSettingsResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
