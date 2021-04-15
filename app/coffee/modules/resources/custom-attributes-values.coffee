###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

resourceProvider = ($repo) ->
    _get = (objectId, resource) ->
        return $repo.queryOne(resource, objectId)

    service = {
        epic: {
            get: (objectId) -> _get(objectId, "custom-attributes-values/epic")
        }
        userstory: {
            get: (objectId) -> _get(objectId, "custom-attributes-values/userstory")
        }
        task: {
            get: (objectId) -> _get(objectId, "custom-attributes-values/task")
        }
        issue: {
            get: (objectId) -> _get(objectId, "custom-attributes-values/issue")
        }
    }

    return (instance) ->
        instance.customAttributesValues = service

module = angular.module("taigaResources")
module.factory("$tgCustomAttributesValuesResourcesProvider", ["$tgRepo", resourceProvider])
