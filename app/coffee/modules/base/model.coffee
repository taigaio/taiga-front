###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class Model
    constructor: (name, data, dataTypes) ->
        @._attrs = data
        @._name = name
        @._dataTypes = dataTypes

        @.setAttrs(data)
        @.initialize()

    realClone: ->
        attrs = _.cloneDeep(@._attrs)

        instance =  new Model(@._name, attrs, @._dataTypes)

        instance._modifiedAttrs = _.cloneDeep(@._modifiedAttrs)
        instance._isModified = _.cloneDeep(@._isModified)

        return instance

    clone: ->
        instance = new Model(@._name, @._attrs, @._dataTypes)
        instance._modifiedAttrs = @._modifiedAttrs
        instance._isModified = @._isModified
        return instance

    applyCasts: ->
        for attrName, castName of @._dataTypes
            castMethod = service.casts[castName]
            if not castMethod
                continue

            @._attrs[attrName] = castMethod(@._attrs[attrName])

    getIdAttrName: ->
        return "id"

    getName: ->
        return @._name

    getAttrs: (patch=false) ->
        if @._attrs.version?
            @._modifiedAttrs.version = @._attrs.version

        if patch
            return _.extend({}, @._modifiedAttrs)
        return _.extend({}, @._attrs, @._modifiedAttrs)

    setAttrs: (attrs) ->
        @._attrs = attrs
        @._modifiedAttrs = {}

        @.applyCasts()
        @._isModified = false

    setAttr: (name, value) ->
        @._modifiedAttrs[name] = value
        @._isModified = true

    initialize: () ->
        self = @

        getter = (name) ->
            return ->
                if typeof(name) == 'string' and name.substr(0,2) == "__"
                    return self[name]

                if name not in _.keys(self._modifiedAttrs)
                    return self._attrs[name]

                return self._modifiedAttrs[name]

        setter = (name) ->
            return (value) ->
                if typeof(name) == 'string' and name.substr(0,2) == "__"
                    self[name] = value
                    return

                if self._attrs[name] != value
                    self._modifiedAttrs[name] = value
                    self._isModified = true
                else
                    delete self._modifiedAttrs[name]

                return

        _.each @_attrs, (value, name) ->
            options =
                get: getter(name)
                set: setter(name)
                enumerable: true
                configurable: true

            Object.defineProperty(self, name, options)

    serialize: () ->
        data =
            "data": _.clone(@_attrs)
            "name": @_name

        return JSON.stringify(data)

    isModified: ->
        return this._isModified

    isAttributeModified: (attribute) ->
        return @._modifiedAttrs[attribute]?

    markSaved: () ->
        @._isModified = false
        @._attrs = @.getAttrs()
        @._modifiedAttrs = {}

    revert: () ->
        @_modifiedAttrs = {}
        @_isModified = false

    @desSerialize = (sdata) ->
        ddata = JSON.parse(sdata)
        model = new Model(ddata.url, ddata.data)
        return model


taiga = @.taiga

class ModelService extends taiga.Service
    @.$inject = ["$q", "$tgUrls", "$tgStorage", "$tgHttp"]

    constructor: (@q, @urls, @storage, @http) ->
        super()

provider = ($q, $http, $gmUrls, $gmStorage) ->
    service = {}
    service.make_model = (name, data, cls=Model, dataTypes={}) ->
        return new cls(name, data, dataTypes)

    service.cls = Model
    service.casts = {
        int: (value) ->
            return parseInt(value, 10)

        float: (value) ->
            return parseFloat(value, 10)
    }

    return service

module = angular.module("taigaBase")
module.factory("$tgModel", ["$q", "$http", "$tgUrls", "$tgStorage", provider])
