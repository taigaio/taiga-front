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
        return $repo.queryOne("roles", id)

    service.list = (projectId) ->
        return $repo.queryMany("roles", {project: projectId})

    return (instance) ->
        instance.roles = service


module = angular.module("taigaResources")
module.factory("$tgRolesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
