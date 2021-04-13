taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($repo) ->
    _list = (projectId, resource) ->
        return $repo.queryMany(resource, {project: projectId})

    service = {
        epic:{
            list: (projectId) -> _list(projectId, "custom-attributes/epic")
        }
        userstory:{
            list: (projectId) -> _list(projectId, "custom-attributes/userstory")
        }
        task:{
            list: (projectId) -> _list(projectId, "custom-attributes/task")
        }
        issue: {
            list: (projectId) -> _list(projectId, "custom-attributes/issue")
        }
    }

    return (instance) ->
        instance.customAttributes = service


module = angular.module("taigaResources")
module.factory("$tgCustomAttributesResourcesProvider", ["$tgRepo", resourceProvider])
