###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

class StorageService extends taiga.Service
    @.$inject = ["$rootScope"]

    constructor: ($rootScope) ->
        super()

    get: (key, _default) ->
        serializedValue = localStorage.getItem(key)
        if serializedValue == null
            return _default or null

        try
            return JSON.parse(serializedValue)
        catch e
            return null

    set: (key, val) ->
        if _.isObject(key)
            _.each key, (val, key) =>
                @set(key, val)
        else
            localStorage.setItem(key, JSON.stringify(val))

    contains: (key) ->
        value = @.get(key)
        return (value != null)

    remove: (key) ->
        localStorage.removeItem(key)

    clear: ->
        localStorage.clear()


module = angular.module("taigaBase")
module.service("$tgStorage", StorageService)
