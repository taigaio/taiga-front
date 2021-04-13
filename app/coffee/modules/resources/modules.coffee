resourceProvider = ($repo) ->
    service = {}

    service.list = (projectId, module) ->
        return $repo.queryOneAttribute("project-modules", projectId, module)

    return (instance) ->
        instance.modules = service


module = angular.module("taigaResources")
module.factory("$tgModulesResourcesProvider", ["$tgRepo", resourceProvider])
