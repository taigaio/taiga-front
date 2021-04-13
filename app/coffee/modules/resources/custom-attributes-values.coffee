taiga = @.taiga

resourceProvider = ($repo) ->
    _get = (objectId, resource) ->
        return $repo.queryOne(resource, objectId)

    service = {
        epic: {
            get: (objectId) -> _get(objectId, "custom-attributes-values/epic")
        }
        userstory: {
            get: (objectId) -> _get(objectId, "custom-attributes-values/userstory")
        }
        task: {
            get: (objectId) -> _get(objectId, "custom-attributes-values/task")
        }
        issue: {
            get: (objectId) -> _get(objectId, "custom-attributes-values/issue")
        }
    }

    return (instance) ->
        instance.customAttributesValues = service

module = angular.module("taigaResources")
module.factory("$tgCustomAttributesValuesResourcesProvider", ["$tgRepo", resourceProvider])
