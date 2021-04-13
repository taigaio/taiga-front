format = (fmt, obj) ->
    obj = _.clone(obj)
    return fmt.replace /%s/g, (match) -> String(obj.shift())

taiga = @.taiga

class UrlsService extends taiga.Service
    @.$inject = ["$tgConfig"]

    constructor: (@config) ->
        @.urls = {}
        @.mainUrl = @config.get("api")

    update: (urls) ->
        @.urls = _.merge(@.urls, urls)

    resolve: ->
        args = _.toArray(arguments)

        if args.length == 0
            throw Error("wrong arguments to setUrls")

        name = args.slice(0, 1)[0]
        url = format(@.urls[name], args.slice(1))

        return format("%s/%s", [
            _.trimEnd(@.mainUrl, "/"),
            _.trimStart(url, "/")
        ])

    resolveAbsolute: ->
        url = @.resolve.apply(@, arguments)
        if (/^https?:\/\//i).test(url)
            return url
        if (/^\//).test(url)
            return "#{window.location.protocol}//#{window.location.host}#{url}"
        return "#{window.location.protocol}//#{window.location.host}/#{url}"


module = angular.module("taigaBase")
module.service('$tgUrls', UrlsService)
