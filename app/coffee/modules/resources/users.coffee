taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($http, $urls) ->
    service = {}

    service.contacts = (userId, options={}) ->
        url = $urls.resolve("user-contacts", userId)
        httpOptions = {headers: {}}

        if not options.enablePagination
            httpOptions.headers["x-disable-pagination"] =  "1"

        return $http.get(url, {}, httpOptions)
            .then (result) ->
                return result.data

    return (instance) ->
        instance.users = service


module = angular.module("taigaResources")
module.factory("$tgUsersResourcesProvider", ["$tgHttp", "$tgUrls", "$q",
                                                    resourceProvider])
