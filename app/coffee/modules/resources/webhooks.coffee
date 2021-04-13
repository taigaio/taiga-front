resourceProvider = ($repo, $urls, $http) ->
    service = {}

    service.list = (projectId) ->
        params = {project: projectId}
        return $repo.queryMany("webhooks", params)

    service.test = (webhookId) ->
        url = $urls.resolve("webhooks-test", webhookId)
        return $http.post(url)

    return (instance) ->
        instance.webhooks = service


module = angular.module("taigaResources")
module.factory("$tgWebhooksResourcesProvider", ["$tgRepo", "$tgUrls", "$tgHttp", resourceProvider])
