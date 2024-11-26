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
        return $repo.queryOne("roles", id)

    service.list = (projectId) ->
        return $repo.queryMany("roles", {project: projectId})

    return (instance) ->
        instance.roles = service


module = angular.module("taigaResources")
module.factory("$tgRolesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
