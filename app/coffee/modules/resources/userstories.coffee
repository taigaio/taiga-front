###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/resources/userstories.coffee
###

taiga = @.taiga

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.get = (projectId, usId) ->
        return $repo.queryOne("userstories", usId)

    service.listUnassigned = (projectId) ->
        params = {"project": projectId, "milestone": "null"}
        return $repo.queryMany("userstories", params)

    service.bulkCreate = (projectId, data) ->
        url = $urls.resolve("bulk-create-us")
        params = {projectId: projectId, bulkStories: data}
        return $http.post(url, params)

    service.bulkUpdateOrder = (projectId, data) ->
        url = $urls.resolve("bulk-update-us-order")
        params = {projectId: projectId, bulkStories: data}
        return $http.post(url, params)

    service.history = (usId) ->
        return $repo.queryOneRaw("history/userstory", usId)

    service.listValues = (projectId, type) ->
        params = {"project": projectId}
        return $repo.queryMany(type, params)

    return (instance) ->
        instance.userstories = service

module = angular.module("taigaResources")
module.factory("$tgUserstoriesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
