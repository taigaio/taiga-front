###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: modules/resources/kanban.coffee
###


taiga = @.taiga

generateHash = taiga.generateHash

resourceProvider = ($storage) ->
    service = {}
    hashSuffixStatusViewModes = "kanban-statusviewmodels"
    hashSuffixStatusColumnModes = "kanban-statuscolumnmodels"

    service.storeStatusColumnModes = (projectId, params) ->
        ns = "#{projectId}:#{hashSuffixStatusColumnModes}"
        hash = generateHash([projectId, ns])
        $storage.set(hash, params)

    service.getStatusColumnModes = (projectId) ->
        ns = "#{projectId}:#{hashSuffixStatusColumnModes}"
        hash = generateHash([projectId, ns])
        return $storage.get(hash) or {}

    return (instance) ->
        instance.kanban = service


module = angular.module("taigaResources")
module.factory("$tgKanbanResourcesProvider", ["$tgStorage", resourceProvider])
