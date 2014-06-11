# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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

taiga = @.taiga

class RepositoryService extends taiga.TaigaService
    @.$inject = ["$http", "$q", "$tgModel", "$tgStorage"]

    constructor: (@http, @q, @model, @storage) ->
        super()

    headers: ->
        token = @.storage.get('token')
        if token
            return {"Authorization":"Bearer #{token}"}
        return {}

    resolveUrlForModel: (model) ->
        idAttrName = model.getIdAttrName()
        return "#{@urls.resolve(model.name)}/#{model[idAttrName]}"

    create: (name, data, dataTypes={}, extraParams={}) ->
        defered = @q.defer()

        params = {
            method: "POST"
            url: @urls.resolve(name)
            headers: headers()
            data: JSON.stringify(data)
            params: extraParams
        }

        promise = @http(params)
        promise.success (_data, _status) =>
            defered.resolve(@model.make_model(name, _data, null, dataTypes))

        promise.error (data, status) =>
            defered.reject(data)

        return defered.promise

    remove: (model) ->
        defered = $q.defer()

        params = {
            method: "DELETE"
            url: @.resolveUrlForModel(model)
            headers: @.headers()
        }

        promise = @http(params)
        promise.success (data, status) ->
            defered.resolve(model)

        promise.error (data, status) ->
            defered.reject(model)

        return defered.promise

    save: (model, extraParams, patch=true) ->
        defered = $q.defer()

        if not model.isModified() and patch
            defered.resolve(model)
            return defered.promise

        params = {
            url: @.resolveUrlForModel(model)
            headers: @.headers()
        }

        if patch
            params.method = "PATCH"
        else
            params.method = "PUT"

        params.data = JSON.stringify(model.getAttrs(patch))
        params = _.extend({}, params, extraParams)

        promise = @http(params)
        promise.success (data, status) =>
            model._isModified = false
            model._attrs = _.extend(model.getAttrs(), data)
            model._modifiedAttrs = {}

            model.applyCasts()
            defered.resolve(model)

        promise.error (data, status) ->
            defered.reject(data)

        return defered.promise

    refresh: (model) ->
        defered = $q.defer()
        params = {
            method: "GET",
            url: @.resolveUrlForModel(model)
            headers: @.headers()
        }

        promise = @http(params)
        promise.success (data, status) ->
            model._modifiedAttrs = {}
            model._attrs = data
            model._isModified = false
            model.applyCasts()
            defered.resolve(model)

        promise.error (data, status) ->
            defered.reject(data)

        return defered.promise


module = angular.module("taigaResources")
module.service("resources", RepositoryService)
