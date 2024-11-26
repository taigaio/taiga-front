###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

    service.getNotifications = (userId, page, onlyUnread) ->
        params = {
            page: page
        }
        if onlyUnread
            params['only_unread'] = true

        url = urlsService.resolve("notifications")

        return http.get(url, params, {
            headers: {
                'x-lazy-pagination': true
            }
        }).then (result) ->
            result = Immutable.fromJS(result)
            paginateResponse = Immutable.Map({
                "data": result.get("data").get("objects"),
                "next": !!result.get("headers")("x-pagination-next"),
                "prev": !!result.get("headers")("x-pagination-prev"),
                "current": result.get("headers")("x-pagination-current"),
                "count": result.get("headers")("x-pagination-count"),
                "total": result.get("data").get("total")
            })
            return paginateResponse

    service.setNotificationAsRead = (notificationId) ->
        url = "#{urlsService.resolve("notifications")}/#{notificationId}/set-as-read"
        return http.patch(url).then (result) ->
            return result

    service.setNotificationsAsRead = () ->
        url = "#{urlsService.resolve("notifications")}/set-as-read"
        return http.post(url).then (result) ->
            return result

    return () ->
        return {"users": service}

Resource.$inject = ["$tgUrls", "$tgHttp", "tgPaginateResponseService"]

module = angular.module("taigaResources2")
module.factory("tgUsersResources", Resource)
