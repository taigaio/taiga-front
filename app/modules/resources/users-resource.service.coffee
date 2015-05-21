Resource = (urlsService, http) ->
    service = {}

    service.getUserBySlug = (userSlug) ->

    service.getStats = (userId) ->
        url = urlsService.resolve("stats", userId)

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        return http.get(url, {}, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)


    service.getContacts = (userId) ->
        url = urlsService.resolve("contacts", userId)

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        return http.get(url, {}, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getTimeline = (userId, page) ->
        params = {
            page: page
        }

        url = urlsService.resolve("timeline-profile")
        url = "#{url}/#{userId}"

        return http.get(url, params).then (result) ->
            return Immutable.fromJS(result.data)

    return () ->
        return {"users": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgUsersResources", Resource)
