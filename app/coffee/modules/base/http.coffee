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
# File: modules/base/http.coffee
###

taiga = @.taiga

class HttpService extends taiga.Service
    @.$inject = ["$http", "$q", "tgLoader", "$tgStorage", "$rootScope", "$cacheFactory", "$translate"]

    constructor: (@http, @q, @tgLoader, @storage, @rootScope, @cacheFactory, @translate) ->
        super()

        @.cache = @cacheFactory("httpget")
    headers: ->
        headers = {}

        # Authorization
        token = @storage.get('token')
        if token
            headers["Authorization"] = "Bearer #{token}"

        # Accept-Language
        lang = @translate.preferredLanguage()
        if lang
            headers["Accept-Language"] = lang

        return headers

    request: (options) ->
        options.headers = _.assign({}, options.headers or {}, @.headers())

        return @http(options)

    get: (url, params, options) ->
        options = _.assign({method: "GET", url: url}, options)
        options.params = params if params

        # prevent duplicated http request
        options.cache = @.cache

        return @.request(options).finally (data) =>
            @.cache.removeAll()

    post: (url, data, params, options) ->
        options = _.assign({method: "POST", url: url}, options)

        options.data = data if data
        options.params = params if params
        options.responseType = 'text'

        return @.request(options)

    put: (url, data, params, options) ->
        options = _.assign({method: "PUT", url: url}, options)
        options.data = data if data
        options.params = params if params
        return @.request(options)

    patch: (url, data, params, options) ->
        options = _.assign({method: "PATCH", url: url}, options)
        options.data = data if data
        options.params = params if params
        return @.request(options)

    delete: (url, data, params, options) ->
        options = _.assign({method: "DELETE", url: url}, options)
        options.data = data if data
        options.params = params if params
        return @.request(options)


module = angular.module("taigaBase")
module.service("$tgHttp", HttpService)
