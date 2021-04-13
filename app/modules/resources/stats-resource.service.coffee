Resource = (urlsService, http) ->
    service = {}

    service.discover = (applicationId, state) ->
        url = urlsService.resolve("stats-discover")
        return http.get(url).then (result) ->
            Immutable.fromJS(result.data)

    return () ->
        return {"stats": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgStatsResource", Resource)
