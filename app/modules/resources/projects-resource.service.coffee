###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: projects-resource.service.coffee
###

pagination = () ->

Resource = (urlsService, http, paginateResponseService) ->
    service = {}

    service.getProjects = (params = {}, pagination = true) ->
        url = urlsService.resolve("projects")

        httpOptions = {}

        if !pagination
            httpOptions = {
                headers: {
                    "x-disable-pagination": "1"
                }
            }

        return http.get(url, params, httpOptions)

    service.getProjectBySlug = (projectSlug) ->
        url = urlsService.resolve("projects")

        url = "#{url}/by_slug?slug=#{projectSlug}"

        return http.get(url)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getProjectsByUserId = (userId, paginate=false) ->
        url = urlsService.resolve("projects")
        httpOptions = {}

        if !paginate
            httpOptions.headers = {
                "x-disable-pagination": "1"
            }

        params = {"member": userId, "order_by": "memberships__user_order"}

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getProjectStats = (projectId) ->
        url = urlsService.resolve("projects")
        url = "#{url}/#{projectId}"

        return http.get(url)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.bulkUpdateOrder = (bulkData) ->
        url = urlsService.resolve("bulk-update-projects-order")
        return http.post(url, bulkData)

    service.getTimeline = (projectId, page) ->
        params = {
            page: page,
            only_relevant: true
        }

        url = urlsService.resolve("timeline-project")
        url = "#{url}/#{projectId}"

        return http.get(url, params, {
            headers: {
                'x-lazy-pagination': true
            }
        }).then (result) ->
            result = Immutable.fromJS(result)
            return paginateResponseService(result)

    service.likeProject = (projectId) ->
        url = urlsService.resolve("project-like", projectId)
        return http.post(url)

    service.unlikeProject = (projectId) ->
        url = urlsService.resolve("project-unlike", projectId)
        return http.post(url)

    service.watchProject = (projectId, notifyLevel) ->
        data = {
            notify_level: notifyLevel
        }
        url = urlsService.resolve("project-watch", projectId)
        return http.post(url, data)

    service.unwatchProject = (projectId) ->
        url = urlsService.resolve("project-unwatch", projectId)
        return http.post(url)

    return () ->
        return {"projects": service}

Resource.$inject = ["$tgUrls", "$tgHttp", "tgPaginateResponseService"]

module = angular.module("taigaResources2")
module.factory("tgProjectsResources", Resource)
