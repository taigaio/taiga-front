class ExternalAppsService extends taiga.Service
    @.$inject = [
        "tgResources"
    ]

    constructor: (@rs) ->

    getApplicationToken: (applicationId, state) ->
        return @rs.externalapps.getApplicationToken(applicationId, state)

    authorizeApplicationToken: (applicationId, state) ->
        return @rs.externalapps.authorizeApplicationToken(applicationId, state)

angular.module("taigaExternalApps").service("tgExternalAppsService", ExternalAppsService)
