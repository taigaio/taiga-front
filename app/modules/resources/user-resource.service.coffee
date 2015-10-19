Resource = (urlsService, http, paginateResponseService) ->
    service = {}

    service.getUserStorage = (key) ->
        url = urlsService.resolve("user-storage")

        if key
            url += '/' + key

        httpOptions = {}

        return http.get(url, {}).then (response) ->
            return response.data.value

    service.setUserStorage = (key, value) ->
        url = urlsService.resolve("user-storage") + '/' + key

        params = {
            key: key,
            value: value
        }

        return http.put(url, params)

    service.createUserStorage = (key, value) ->
        url = urlsService.resolve("user-storage")

        params = {
            key: key,
            value: value
        }

        return http.post(url, params)

    return () ->
        return {"user": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgUserResources", Resource)
