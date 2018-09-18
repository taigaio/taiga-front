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
# File: resources/projects-resource.service.coffee
###

pagination = () ->

Resource = (urlsService, http, paginateResponseService) ->
    service = {}

    service.create = (data) ->
        url = urlsService.resolve('projects')

        return http.post(url, JSON.stringify(data))
            .then (result) => return Immutable.fromJS(result.data)

    service.duplicate = (projectId, data) ->

        url = urlsService.resolve("projects")
        url = "#{url}/#{projectId}/duplicate"

        members = data.users.map (member) => {"id": member}

        params = {
            "name": data.name,
            "description": data.description,
            "is_private": data.is_private,
            "users": members
        }

        return http.post(url, params)

    service.getProjects = (params = {}, pagination = true) ->
        url = urlsService.resolve("projects")

        httpOptions = {}

        if !pagination
            httpOptions = {
                headers: {
                    "x-lazy-pagination": true
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

        params = {"member": userId, "order_by": "user_order"}

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
            live_notify_level: notifyLevel
        }
        url = urlsService.resolve("project-watch", projectId)
        return http.post(url, data)

    service.unwatchProject = (projectId) ->
        url = urlsService.resolve("project-unwatch", projectId)
        return http.post(url)

    service.contactProject = (projectId, message) ->
        params = {
            project: projectId,
            comment: message
        }

        url = urlsService.resolve("project-contact")
        return http.post(url, params)

    service.transferValidateToken = (projectId, token) ->
        data = {
            token: token
        }
        url = urlsService.resolve("project-transfer-validate-token", projectId)
        return http.post(url, data)

    service.transferAccept = (projectId, token, reason) ->
        data = {
            token: token
            reason: reason
        }
        url = urlsService.resolve("project-transfer-accept", projectId)
        return http.post(url, data)

    service.transferReject = (projectId, token, reason) ->
        data = {
            token: token
            reason: reason
        }
        url = urlsService.resolve("project-transfer-reject", projectId)
        return http.post(url, data)

    service.transferRequest = (projectId) ->
        url = urlsService.resolve("project-transfer-request", projectId)
        return http.post(url)

    service.transferStart = (projectId, userId, reason) ->
        data = {
            user: userId,
            reason: reason
        }

        url = urlsService.resolve("project-transfer-start", projectId)
        return http.post(url, data)

    return () ->
        return {"projects": service}

Resource.$inject = ["$tgUrls", "$tgHttp", "tgPaginateResponseService"]

module = angular.module("taigaResources2")
module.factory("tgProjectsResources", Resource)
