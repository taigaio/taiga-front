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
        return $repo.queryOne("user-project-settings", id)

    service.list = (filters) ->
        params = _.extend({}, params, filters or {})
        return $repo.queryMany("user-project-settings", params)

    return (instance) ->
        instance.userProjectSettings = service


module = angular.module("taigaResources")
module.factory("$tgUserProjectSettingsResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
