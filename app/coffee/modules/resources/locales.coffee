taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($repo) ->
    service = {
        list: -> return $repo.queryMany("locales")
    }

    return (instance) ->
        instance.locales = service


module = angular.module("taigaResources")
module.factory("$tgLocalesResourcesProvider", ["$tgRepo", resourceProvider])

