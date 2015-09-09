Resource = (urlsService, http) ->
    service = {}

    service.getApplicationToken = (applicationId, state) ->
        url = urlsService.resolve("applications")
        url = "#{url}/#{applicationId}/token?state=#{state}"
        return http.get(url).then (result) ->
            Immutable.fromJS(result.data)

    service.authorizeApplicationToken = (applicationId, state) ->
        url = urlsService.resolve("application-tokens")
        url = "#{url}/authorize"
        data = {
            "state": state
            "application": applicationId
        }

        return http.post(url, data).then (result) ->
            Immutable.fromJS(result.data)

    return () ->
        return {"externalapps": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgExternalAppsResource", Resource)
