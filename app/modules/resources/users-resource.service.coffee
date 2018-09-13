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
# File: resources/users-resource.service.coffee
###

Resource = (urlsService, http, paginateResponseService) ->
    service = {}

    service.getUserByUsername = (username) ->
        url = urlsService.resolve("by_username")

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        params = {
            username: username
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getStats = (userId) ->
        url = urlsService.resolve("user-stats", userId)

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        return http.get(url, {}, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getContacts = (userId, excludeProjectId) ->
        url = urlsService.resolve("user-contacts", userId)

        params = {}
        params.exclude_project = excludeProjectId if excludeProjectId?

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getLiked = (userId, page, type, q) ->
        url = urlsService.resolve("user-liked", userId)

        params = {}
        params.page = page if page?
        params.type = type if type?
        params.q = q if q?

        params.only_relevant = true

        return http.get(url, params, {
            headers: {
                'x-lazy-pagination': true
            }
        }).then (result) ->
            result = Immutable.fromJS(result)
            return paginateResponseService(result)

    service.getVoted = (userId, page, type, q) ->
        url = urlsService.resolve("user-voted", userId)

        params = {}
        params.page = page if page?
        params.type = type if type?
        params.q = q if q?

        return http.get(url, params, {
            headers: {
                'x-lazy-pagination': true
            }
        }).then (result) ->
            result = Immutable.fromJS(result)
            return paginateResponseService(result)

    service.getWatched = (userId, page, type, q) ->
        url = urlsService.resolve("user-watched", userId)

        params = {}
        params.page = page if page?
        params.type = type if type?
        params.q = q if q?

        return http.get(url, params, {
            headers: {
                'x-lazy-pagination': true
            }
        }).then (result) ->
            result = Immutable.fromJS(result)
            return paginateResponseService(result)

    service.getProfileTimeline = (userId, page) ->
        params = {
            page: page
        }

        url = urlsService.resolve("timeline-profile")
        url = "#{url}/#{userId}"

        return http.get(url, params, {
            headers: {
                'x-lazy-pagination': true
            }
        }).then (result) ->
            result = Immutable.fromJS(result)
            return paginateResponseService(result)

    service.getUserTimeline = (userId, page) ->
        params = {
            page: page,
            only_relevant: true
        }

        url = urlsService.resolve("timeline-user")
        url = "#{url}/#{userId}"


        return http.get(url, params, {
            headers: {
                'x-lazy-pagination': true
            }
        }).then (result) ->
            result = Immutable.fromJS(result)
            return paginateResponseService(result)

    return () ->
        return {"users": service}

Resource.$inject = ["$tgUrls", "$tgHttp", "tgPaginateResponseService"]

module = angular.module("taigaResources2")
module.factory("tgUsersResources", Resource)
