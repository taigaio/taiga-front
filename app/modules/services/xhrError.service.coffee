class xhrError extends taiga.Service
    @.$inject = [
        "$q",
        "$location",
        "$tgNavUrls"
    ]

    constructor: (@q, @location, @navUrls) ->

    notFound: () ->
        @location.path(@navUrls.resolve("not-found"))
        @location.replace()

    permissionDenied: () ->
        @location.path(@navUrls.resolve("permission-denied"))
        @location.replace()

    response: (xhr) ->
        if xhr
            if xhr.status == 404
                @.notFound()

            else if xhr.status == 403
                @.permissionDenied()

        return @q.reject(xhr)

angular.module("taigaCommon").service("tgXhrErrorService", xhrError)
