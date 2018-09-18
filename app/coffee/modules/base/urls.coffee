###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: modules/base/urls.coffee
###

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
