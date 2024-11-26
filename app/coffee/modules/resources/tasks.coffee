###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

    service.bulkUpdateMilestone = (projectId, milestoneId, data) ->
        url = $urls.resolve("bulk-update-task-milestone")
        params = {project_id: projectId, milestone_id: milestoneId, bulk_tasks: data}
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

    service.promoteToUserStory = (taskId, projectId) ->
        url = $urls.resolve("promote-task-to-us", taskId)
        data = {project_id: projectId}
        return $http.post(url, data)

    return (instance) ->
        instance.tasks = service


module = angular.module("taigaResources")
module.factory("$tgTasksResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", "$tgStorage", resourceProvider])
