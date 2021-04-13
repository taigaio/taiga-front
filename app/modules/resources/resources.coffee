services = [
    "tgProjectsResources",
    "tgUserResources",
    "tgUsersResources",
    "tgUserstoriesResource",
    "tgTasksResource",
    "tgIssuesResource",
    "tgExternalAppsResource",
    "tgAttachmentsResource",
    "tgStatsResource",
    "tgHistory",
    "tgEpicsResource",
    "tgTrelloImportResource",
    "tgJiraImportResource",
    "tgGithubImportResource",
    "tgAsanaImportResource"
]

Resources = ($injector) ->
    for serviceName in services
        serviceFn = $injector.get(serviceName)

        service = $injector.invoke(serviceFn)

        for serviceProperty in Object.keys(service)
            if @[serviceProperty]
                console.warn("repeated resource " + serviceProperty)

            @[serviceProperty] = service[serviceProperty]

    return @


Resources.$inject = ["$injector"]

angular.module("taigaResources2").service("tgResources", Resources)
