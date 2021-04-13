class xhrError extends taiga.Service
    @.$inject = [
        "$q",
        "tgErrorHandlingService"
    ]

    constructor: (@q, @errorHandlingService) ->

    notFound: () ->
        @errorHandlingService.notfound()

    permissionDenied: () ->
        @errorHandlingService.permissionDenied()

    response: (xhr) ->
        if xhr
            if xhr.status == 404
                @.notFound()

            else if xhr.status == 403
                @.permissionDenied()

        return @q.reject(xhr)

angular.module("taigaCommon").service("tgXhrErrorService", xhrError)
