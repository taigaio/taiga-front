###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

generateHash = taiga.generateHash

resourceProvider = ($storage) ->
    service = {}
    hashSuffixStatusViewModes = "kanban-statusviewmodels"
    hashSuffixStatusColumnModes = "kanban-statuscolumnmodels"
    hashSuffixSwimlanesModes = "kanban-swimlanesmodels"

    service.storeStatusColumnModes = (projectId, params) ->
        ns = "#{projectId}:#{hashSuffixStatusColumnModes}"
        hash = generateHash([projectId, ns])
        $storage.set(hash, params)

    service.getStatusColumnModes = (projectId) ->
        ns = "#{projectId}:#{hashSuffixStatusColumnModes}"
        hash = generateHash([projectId, ns])
        return $storage.get(hash) or {}

    service.storeSwimlanesModes = (projectId, params) ->
        ns = "#{projectId}:#{hashSuffixSwimlanesModes}"
        hash = generateHash([projectId, ns])
        $storage.set(hash, params)

    service.getSwimlanesModes = (projectId) ->
        ns = "#{projectId}:#{hashSuffixSwimlanesModes}"
        hash = generateHash([projectId, ns])
        return $storage.get(hash) or {}

    return (instance) ->
        instance.kanban = service


module = angular.module("taigaResources")
module.factory("$tgKanbanResourcesProvider", ["$tgStorage", resourceProvider])
