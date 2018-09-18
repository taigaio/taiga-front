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
# File: modules/resources/custom-attributes-values.coffee
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
