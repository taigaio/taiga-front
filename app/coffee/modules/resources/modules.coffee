###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

resourceProvider = ($repo) ->
    service = {}

    service.list = (projectId, module) ->
        return $repo.queryOneAttribute("project-modules", projectId, module)

    return (instance) ->
        instance.modules = service


module = angular.module("taigaResources")
module.factory("$tgModulesResourcesProvider", ["$tgRepo", resourceProvider])
