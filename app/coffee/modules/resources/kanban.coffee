###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
