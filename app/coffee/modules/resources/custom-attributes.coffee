###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
