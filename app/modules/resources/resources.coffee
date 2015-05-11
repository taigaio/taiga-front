services = [
    "tgProjectsResources"
]

Resources = ($injector) ->
    for serviceName in services
        serviceFn = $injector.get(serviceName)

        service = $injector.invoke(serviceFn)

        for serviceProperty in Object.keys(service)
            if @[serviceProperty]
                console.warm("repeated resource " + serviceProperty)

            @[serviceProperty] = service[serviceProperty]

    return @


Resources.$inject = ["$injector"]

angular.module("taigaResources2").service("tgResources", Resources)
