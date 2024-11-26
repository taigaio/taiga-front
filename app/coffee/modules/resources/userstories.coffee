###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

generateHash = taiga.generateHash

hashShowTags = 'backlog-tags'

resourceProvider = ($repo, $http, $urls, $storage, $q) ->
    service = {}
    hashSuffix = "userstories-queryparams"

    service.get = (projectId, usId, extraParams) ->
        params = service.getQueryParams(projectId)
        params.project = projectId

        params = _.extend({}, params, extraParams)

        return $repo.queryOne("userstories", usId, params)

    service.getByRef = (projectId, ref, extraParams = {}) ->
        params = service.getQueryParams(projectId)
        params.project = projectId
        params.ref = ref
        params = _.extend({}, params, extraParams)
        # TODO: fix api performance issue
        if params.milestone == 'null'
            delete params.milestone
            delete params['no-milestone']

        return $repo.queryOne("userstories", "by_ref", params)

    service.listInAllProjects = (filters) ->
        return $repo.queryMany("userstories", filters)

    service.filtersData = (params) ->
        return $repo.queryOneRaw("userstories-filters", null, params)

    service.listUnassigned = (projectId, filters, pageSize, store = true) ->
        params = {"project": projectId, "milestone": "null"}
        params = _.extend({}, params, filters or {})
        if store
            service.storeQueryParams(projectId, params)

        return $repo.queryMany("userstories", _.extend(params, {
            page_size: pageSize
        }), {
            enablePagination: true
        }, true)

    service.listAll = (projectId, filters) ->
        params = {"project": projectId}
        params = _.extend({}, params, filters or {})
        service.storeQueryParams(projectId, params)

        return $repo.queryMany("userstories", params)

    service.bulkCreate = (projectId, status, bulk, swimlane) ->
        data = {
            project_id: projectId
            status_id: status
            bulk_stories: bulk
            swimlane_id: swimlane
        }

        url = $urls.resolve("bulk-create-us")

        return $http.post(url, data)

    service.upvote = (userStoryId) ->
        url = $urls.resolve("userstory-upvote", userStoryId)
        return $http.post(url)

    service.downvote = (userStoryId) ->
        url = $urls.resolve("userstory-downvote", userStoryId)
        return $http.post(url)

    service.watch = (userStoryId) ->
        url = $urls.resolve("userstory-watch", userStoryId)
        return $http.post(url)

    service.unwatch = (userStoryId) ->
        url = $urls.resolve("userstory-unwatch", userStoryId)
        return $http.post(url)

    service.bulkUpdateBacklogOrder = (projectId, milestoneId, afterUserstoryId, beforeUserstoryId, bulkUserstories) ->
        url = $urls.resolve("bulk-update-us-backlog-order")
        params = {project_id: projectId, bulk_userstories: bulkUserstories}

        if milestoneId
            params.milestone_id = milestoneId

        if afterUserstoryId
            params.after_userstory_id = afterUserstoryId

        else if  beforeUserstoryId
            params.before_userstory_id = beforeUserstoryId

        return $http.post(url, params)

    service.bulkUpdateMilestone = (projectId, milestoneId, data) ->
        url = $urls.resolve("bulk-update-us-milestone")
        params = {project_id: projectId, milestone_id: milestoneId, bulk_stories: data}
        return $http.post(url, params)

    service.bulkUpdateKanbanOrder = (projectId, statusId, swimlaneId, afterUserstoryId, beforeUserstoryId, bulkUserstories) ->
        url = $urls.resolve("bulk-update-us-kanban-order")
        params = {
            project_id: projectId,
            status_id: statusId,
            bulk_userstories: bulkUserstories
        }

        if afterUserstoryId
            params.after_userstory_id = afterUserstoryId

        else if  beforeUserstoryId
            params.before_userstory_id = beforeUserstoryId

        if swimlaneId
            params.swimlane_id = swimlaneId

        return $http.post(url, params)

    service.listValues = (projectId, type) ->
        params = {"project": projectId}
        service.storeQueryParams(projectId, params)
        return $repo.queryMany(type, params)

    service.createDefaultValues = (projectId, type) ->
        data = {"project_id": projectId}
        url = $urls.resolve("#{type}-create-default")
        return $http.post(url, data)

    service.editStatus = (statusId, wip_limit) ->
        url = $urls.resolve("userstory-statuses")
        url = "#{url}/#{statusId}"
        params = {
            wip_limit
        }
        return $http.patch(url, params)

    service.storeQueryParams = (projectId, params) ->
        ns = "#{projectId}:#{hashSuffix}"
        hash = generateHash([projectId, ns])
        $storage.set(hash, params)

    service.getQueryParams = (projectId) ->
        ns = "#{projectId}:#{hashSuffix}"
        hash = generateHash([projectId, ns])
        return $storage.get(hash) or {}

    service.storeBacklog = (projectId, ids) ->
        ns = "#{projectId}:backlog-ids"
        hash = generateHash([projectId, ns])
        $storage.set(hash, ids)

    service.getBacklog = (projectId) ->
        ns = "#{projectId}:backlog-ids"
        hash = generateHash([projectId, ns])
        return $storage.get(hash) or []

    service.storeShowTags = (projectId, params) ->
        ns = "#{projectId}:#{hashShowTags}"
        hash = generateHash([projectId, ns])
        $storage.set(hash, params)

    service.getShowTags = (projectId) ->
        ns = "#{projectId}:#{hashShowTags}"
        hash = generateHash([projectId, ns])
        return $storage.get(hash)

    return (instance) ->
        instance.userstories = service

module = angular.module("taigaResources")
module.factory("$tgUserstoriesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", "$tgStorage", "$q", resourceProvider])
