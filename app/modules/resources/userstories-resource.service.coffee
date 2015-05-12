Resource = (urlsService, http) ->
    service = {}

    service.listInAllProjects = (params) ->
        url = urlsService.resolve("userstories")

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    return () ->
        return {"userstories": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgUserstoriesResource", Resource)
