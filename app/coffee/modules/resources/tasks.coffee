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
# File: modules/resources/tasks.coffee
###


taiga = @.taiga

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.get = (projectId, taskId) ->
        return $repo.queryOne("tasks", taskId)

    service.list = (projectId, sprintId=null, userStoryId=null) ->
        params = {project: projectId}
        params.milestone = sprintId if sprintId
        params.user_story = userStoryId if userStoryId
        return $repo.queryMany("tasks", params)

    service.bulkCreate = (projectId, sprintId, usId, data) ->
        url = $urls.resolve("bulk-create-tasks")
        params = {project_id: projectId, sprint_id: sprintId, us_id: usId, bulk_tasks: data}
        return $http.post(url, params).then (result) ->
            return result.data

    service.history = (taskId) ->
        return $repo.queryOneRaw("history/task", taskId)

    service.listValues = (projectId, type) ->
        params = {"project": projectId}
        return $repo.queryMany(type, params)

    return (instance) ->
        instance.tasks = service


module = angular.module("taigaResources")
module.factory("$tgTasksResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
