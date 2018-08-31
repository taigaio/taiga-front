###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/resources/tasks.coffee
###


taiga = @.taiga

generateHash = taiga.generateHash

resourceProvider = ($repo, $http, $urls, $storage) ->
    service = {}
    hashSuffix = "tasks-queryparams"
    hashSuffixStatusColumnModes = "tasks-statuscolumnmodels"
    hashSuffixUsRowModes = "tasks-usrowmodels"

    service.get = (projectId, taskId, extraParams) ->
        params = service.getQueryParams(projectId)
        params.project = projectId

        params = _.extend({}, params, extraParams)

        return $repo.queryOne("tasks", taskId, params)

    service.getByRef = (projectId, ref, extraParams) ->
        params = service.getQueryParams(projectId)
        params.project = projectId
        params.ref = ref

        params = _.extend({}, params, extraParams)

        return $repo.queryOne("tasks", "by_ref", params)

    service.listInAllProjects = (filters) ->
        return $repo.queryMany("tasks", filters)

    service.filtersData = (params) ->
        return $repo.queryOneRaw("task-filters", null, params)

    service.list = (projectId, sprintId=null, userStoryId=null, params) ->
        params = _.merge(params, {project: projectId, order_by: 'us_order'})
        params.milestone = sprintId if sprintId
        params.user_story = userStoryId if userStoryId
        service.storeQueryParams(projectId, params)
        return $repo.queryMany("tasks", params)

    service.bulkCreate = (projectId, sprintId, usId, data) ->
        url = $urls.resolve("bulk-create-tasks")
        params = {project_id: projectId, milestone_id: sprintId, us_id: usId, bulk_tasks: data}
        return $http.post(url, params).then (result) ->
            return result.data

    service.upvote = (taskId) ->
        url = $urls.resolve("task-upvote", taskId)
        return $http.post(url)

    service.downvote = (taskId) ->
        url = $urls.resolve("task-downvote", taskId)
        return $http.post(url)

    service.watch = (taskId) ->
        url = $urls.resolve("task-watch", taskId)
        return $http.post(url)

    service.unwatch = (taskId) ->
        url = $urls.resolve("task-unwatch", taskId)
        return $http.post(url)

    service.bulkUpdateTaskTaskboardOrder = (projectId, data) ->
        url = $urls.resolve("bulk-update-task-taskboard-order")
        params = {project_id: projectId, bulk_tasks: data}
        return $http.post(url, params)

    service.reorder = (id, data, setOrders) ->
        url = $urls.resolve("tasks") + "/#{id}"

        options = {"headers": {"set-orders": JSON.stringify(setOrders)}}

        return $http.patch(url, data, null, options)
            .then (result) -> result.data

    service.listValues = (projectId, type) ->
        params = {"project": projectId}
        return $repo.queryMany(type, params)

    service.createDefaultValues = (projectId, type) ->
        data = {"project_id": projectId}
        url = $urls.resolve("#{type}-create-default")
        return $http.post(url, data)

    service.storeQueryParams = (projectId, params) ->
        ns = "#{projectId}:#{hashSuffix}"
        hash = generateHash([projectId, ns])
        $storage.set(hash, params)

    service.getQueryParams = (projectId) ->
        ns = "#{projectId}:#{hashSuffix}"
        hash = generateHash([projectId, ns])
        return $storage.get(hash) or {}

    service.storeStatusColumnModes = (projectId, params) ->
        ns = "#{projectId}:#{hashSuffixStatusColumnModes}"
        hash = generateHash([projectId, ns])
        $storage.set(hash, params)

    service.getStatusColumnModes = (projectId) ->
        ns = "#{projectId}:#{hashSuffixStatusColumnModes}"
        hash = generateHash([projectId, ns])
        return $storage.get(hash) or {}

    service.storeUsRowModes = (projectId, sprintId, params) ->
        ns = "#{projectId}:#{hashSuffixUsRowModes}"
        hash = generateHash([projectId, sprintId, ns])

        $storage.set(hash, params)

    service.getUsRowModes = (projectId, sprintId) ->
        ns = "#{projectId}:#{hashSuffixUsRowModes}"
        hash = generateHash([projectId, sprintId, ns])

        return $storage.get(hash) or {}

    return (instance) ->
        instance.tasks = service


module = angular.module("taigaResources")
module.factory("$tgTasksResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", "$tgStorage", resourceProvider])
