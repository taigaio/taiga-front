###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($repo) ->
    _list = (projectId, resource) ->
        return $repo.queryMany(resource, {project: projectId})

    service = {
        epic:{
            list: (projectId) -> _list(projectId, "custom-attributes/epic")
        }
        userstory:{
            list: (projectId) -> _list(projectId, "custom-attributes/userstory")
        }
        task:{
            list: (projectId) -> _list(projectId, "custom-attributes/task")
        }
        issue: {
            list: (projectId) -> _list(projectId, "custom-attributes/issue")
        }
    }

    return (instance) ->
        instance.customAttributes = service


module = angular.module("taigaResources")
module.factory("$tgCustomAttributesResourcesProvider", ["$tgRepo", resourceProvider])
