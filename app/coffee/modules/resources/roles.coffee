taiga = @.taiga

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.get = (id) ->
        return $repo.queryOne("roles", id)

    service.list = (projectId) ->
        return $repo.queryMany("roles", {project: projectId})

    return (instance) ->
        instance.roles = service


module = angular.module("taigaResources")
module.factory("$tgRolesResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
