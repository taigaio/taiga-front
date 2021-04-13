taiga = @.taiga

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.get = (id) ->
        return $repo.queryOne("notify-policies", id)

    service.list = (filters) ->
        params = _.extend({}, params, filters or {})
        return $repo.queryMany("notify-policies", params)

    return (instance) ->
        instance.notifyPolicies = service


module = angular.module("taigaResources")
module.factory("$tgNotifyPoliciesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
