###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

resourceProvider = ($repo) ->
    service = {}

    service.list = (projectId, module) ->
        return $repo.queryOneAttribute("project-modules", projectId, module)

    return (instance) ->
        instance.modules = service


module = angular.module("taigaResources")
module.factory("$tgModulesResourcesProvider", ["$tgRepo", resourceProvider])
