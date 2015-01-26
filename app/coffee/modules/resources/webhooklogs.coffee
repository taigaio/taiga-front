resourceProvider = ($repo, $urls, $http) ->
    service = {}

    service.list = (webhookId) ->
        params = {webhook: webhookId}
        return $repo.queryMany("webhooklogs", params)

    service.resend = (webhooklogId) ->
        url = $urls.resolve("webhooklogs-resend", webhooklogId)
        return $http.post(url)

    return (instance) ->
        instance.webhooklogs = service


module = angular.module("taigaResources")
module.factory("$tgWebhookLogsResourcesProvider", ["$tgRepo", "$tgUrls", "$tgHttp", resourceProvider])
