class xhrError extends taiga.Service
    @.$inject = [
        "$q",
        "$location",
        "$tgNavUrls"
    ]

    constructor: (@q, @location, @navUrls) ->

    response: (xhr) ->
        if xhr
            if xhr.status == 404
                @location.path(@navUrls.resolve("not-found"))
                @location.replace()
            else if xhr.status == 403
                @location.path(@navUrls.resolve("permission-denied"))
                @location.replace()

        return @q.reject(xhr)

angular.module("taigaCommon").service("tgXhrErrorService", xhrError)
